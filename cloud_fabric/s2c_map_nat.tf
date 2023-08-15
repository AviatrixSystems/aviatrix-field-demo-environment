module "avx_landing_zone" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.6.3"

  cloud                            = "aws"
  name                             = "operations-aws-spoke-landing-zone"
  cidr                             = local.cidrs.avx_landing
  region                           = var.transit_aws_palo_firenet_region
  account                          = var.aws_operations_account_name
  instance_size                    = "t3.micro"
  included_advertised_spoke_routes = "10.99.2.0/24,10.7.2.0/24"

  transit_gw = module.backbone.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  ha_gw      = false
  attached   = true
}

module "vpc" {
  source                = "terraform-aws-modules/vpc/aws"
  version               = "5.1.1"
  name                  = "aws-s2c"
  cidr                  = local.cidrs.onprem
  secondary_cidr_blocks = []

  azs             = ["${var.onprem_region}a", "${var.onprem_region}b"]
  private_subnets = [cidrsubnet(local.cidrs.onprem, 4, 0), cidrsubnet(local.cidrs.onprem, 4, 1)]
  public_subnets  = [cidrsubnet(local.cidrs.onprem, 4, 2), cidrsubnet(local.cidrs.onprem, 4, 3)]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = var.common_tags
  providers = {
    aws = aws.onprem
  }
}

resource "aws_customer_gateway" "s2c" {
  bgp_asn    = 65106
  ip_address = module.avx_landing_zone.spoke_gateway.eip
  type       = "ipsec.1"

  tags = {
    Name = "aws-s2c"
  }
  provider = aws.onprem
}

resource "aws_vpn_gateway" "s2c" {
  vpc_id          = module.vpc.vpc_id
  amazon_side_asn = 65000

  tags = {
    Name = "aws-s2c"
  }
  provider = aws.onprem
}

resource "aws_vpn_connection" "s2c" {
  vpn_gateway_id        = aws_vpn_gateway.s2c.id
  customer_gateway_id   = aws_customer_gateway.s2c.id
  type                  = "ipsec.1"
  static_routes_only    = true
  tunnel1_inside_cidr   = "169.254.100.0/30"
  tunnel1_preshared_key = var.s2c_shared_secret
  provider              = aws.onprem
}

resource "aws_vpn_connection_route" "s2c" {
  destination_cidr_block = "10.0.0.0/8"
  vpn_connection_id      = aws_vpn_connection.s2c.id
  provider               = aws.onprem
}

# TODO: This does not apply on a fresh deploy - for_each values unknown
resource "aws_route" "s2c" {
  for_each               = toset(concat(module.vpc.public_route_table_ids, module.vpc.private_route_table_ids))
  route_table_id         = each.value
  destination_cidr_block = "10.0.0.0/8"
  gateway_id             = aws_vpn_gateway.s2c.id
  provider               = aws.onprem
  depends_on             = [module.vpc]
}

resource "aviatrix_site2cloud" "spoke_side" {
  vpc_id                     = module.avx_landing_zone.vpc.vpc_id
  connection_name            = "SaoPaulo"
  connection_type            = "mapped"
  remote_gateway_type        = "avx"
  tunnel_type                = "route"
  ha_enabled                 = false
  enable_active_active       = false
  primary_cloud_gateway_name = module.avx_landing_zone.spoke_gateway.gw_name
  remote_gateway_ip          = aws_vpn_connection.s2c.tunnel1_address
  custom_mapped              = false
  pre_shared_key             = var.s2c_shared_secret
  backup_pre_shared_key      = var.s2c_shared_secret
  forward_traffic_to_transit = true
  remote_subnet_cidr         = local.cidrs.onprem
  remote_subnet_virtual      = "10.99.2.0/24"
  local_subnet_cidr          = "10.1.2.0/24,10.2.2.0/24,10.3.2.0/24,10.4.2.0/24,10.5.2.0/24,10.6.2.0/24,10.40.251.0/24,10.50.251.0/24"
  local_subnet_virtual       = "10.91.2.0/24,10.92.2.0/24,10.93.2.0/24,10.94.2.0/24,10.95.2.0/24,10.96.2.0/24,10.97.2.0/24,10.98.2.0/24"
}

module "operations_onprem" {
  source     = "./mc-instance"
  name       = "operations-onprem-app"
  vpc_id     = module.vpc.vpc_id
  subnet_id  = module.vpc.public_subnets[0]
  cloud      = "aws"
  public_key = var.public_key
  password   = var.workload_instance_password
  private_ip = "10.5.2.40"
  common_tags = merge(var.common_tags, {
    Department  = "operations"
    Application = "onprem"
    Environment = "s2c"
  })

  user_data_templatefile = templatefile("${var.workload_template_path}/gatus.tpl",
    {
      name     = "operations-onprem-app"
      domain   = "demo.aviatrixtest.com"
      password = var.workload_instance_password
      apps = join(",", [
        "10.91.2.10",
        "10.92.2.10",
        "10.93.2.20",
        "10.94.2.10",
        "10.95.2.10"
      ])
      external = join(",", [])
      interval = "30"
  })
  providers = {
    aws = aws.onprem
  }
}
