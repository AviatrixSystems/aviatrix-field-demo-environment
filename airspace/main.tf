# https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-transit-deployment-framework/aviatrix/latest
module "multicloud_transit" {
  source          = "terraform-aviatrix-modules/mc-transit-deployment-framework/aviatrix"
  version         = "v1.1.0"
  transit_firenet = local.transit_firenet
}

# https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-spoke/aviatrix/latest
module "spokes" {
  for_each = { for spoke in local.regional_spokes : "${spoke.avx_account}-${spoke.spoke}" => spoke }
  source   = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version  = "1.5.0"

  cloud         = each.value.cloud
  name          = "${each.value.avx_account}-spoke-${each.value.spoke}"
  cidr          = each.value.spoke == "qa" ? cidrsubnet("${trimsuffix(each.value.transit_cidr, "23")}16", 8, 3) : each.value.spoke == "prod" ? cidrsubnet("${trimsuffix(each.value.transit_cidr, "23")}16", 8, 4) : cidrsubnet("${trimsuffix(each.value.transit_cidr, "23")}16", 8, 2)
  region        = each.value.region
  account       = each.value.avx_account
  instance_size = each.value.cloud == "aws" ? "t3.micro" : each.value.cloud == "gcp" ? "n1-standard-1" : each.value.cloud == "azure" ? "Standard_B1ms" : each.value.cloud == "oci" ? "VM.Standard2.2" : each.value.cloud == "ali" ? "ecs.g5ne.large" : null

  transit_gw = module.multicloud_transit.transit["${each.value.cloud}_${replace(lower(each.value.region), "/[ -]/", "_")}"].transit_gateway.gw_name
  ha_gw      = false
  attached   = true
}


# Public subnet filter gateway
data "aws_route_table" "spoke_dev_public_1" {
  subnet_id = module.spokes["accounting-aws-dev"].vpc.public_subnets[0].subnet_id
  provider  = aws.accounting
}

data "aws_route_table" "spoke_dev_public_2" {
  subnet_id = module.spokes["accounting-aws-dev"].vpc.public_subnets[1].subnet_id
  provider  = aws.accounting
}

resource "aviatrix_gateway" "accounting_psf_dev" {
  cloud_type                                  = 1
  account_name                                = var.aws_accounting_account_name
  gw_name                                     = "accounting-aws-psf-dev"
  vpc_id                                      = module.spokes["accounting-aws-dev"].vpc.vpc_id
  vpc_reg                                     = module.spokes["accounting-aws-dev"].vpc.region
  gw_size                                     = "t3.micro"
  subnet                                      = cidrsubnet(module.spokes["accounting-aws-dev"].vpc.cidr, 2, 1)
  zone                                        = "${module.spokes["accounting-aws-dev"].vpc.region}a"
  enable_public_subnet_filtering              = true
  public_subnet_filtering_route_tables        = [data.aws_route_table.spoke_dev_public_1.id, data.aws_route_table.spoke_dev_public_2.id]
  public_subnet_filtering_guard_duty_enforced = true
  single_az_ha                                = true
  enable_encrypt_volume                       = true
  lifecycle {
    ignore_changes = [public_subnet_filtering_route_tables]
  }
}
