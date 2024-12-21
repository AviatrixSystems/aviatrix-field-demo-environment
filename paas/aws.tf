module "vpc" {
  for_each = toset(local.cps)
  source   = "terraform-aws-modules/vpc/aws"
  version  = "5.13.0"

  name = "${each.value}-vpc"
  cidr = "10.1.${index(local.cps, each.value) + 1}.0/24"

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = [cidrsubnet("10.1.${index(local.cps, each.value) + 1}.0/24", 4, 0), cidrsubnet("10.1.${index(local.cps, each.value) + 1}.0/24", 4, 1), cidrsubnet("10.1.${index(local.cps, each.value) + 1}.0/24", 4, 2)]
  public_subnets  = [cidrsubnet("10.1.${index(local.cps, each.value) + 1}.0/24", 4, 3), cidrsubnet("10.1.${index(local.cps, each.value) + 1}.0/24", 4, 4), cidrsubnet("10.1.${index(local.cps, each.value) + 1}.0/24", 4, 5)]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false
}

module "gatus_az1" {
  for_each             = toset(local.cps)
  source               = "github.com/aviatrix-internal-only-org/avxlabs-mc-instance"
  name                 = "${each.value}-egress-az1"
  vpc_id               = module.vpc[each.value].vpc_id
  subnet_id            = module.vpc[each.value].private_subnets[0]
  iam_instance_profile = aws_iam_role.ssm.name
  cloud                = "aws"
  instance_size        = "t3.micro"
  public_key           = local.tfvars.ssh_public_key
  password             = local.tfvars.workload_instance_password
  private_ip           = "10.1.${index(local.cps, each.value) + 1}.10"

  user_data_templatefile = templatefile("${path.module}/templates/egress.tpl",
    {
      name     = "${each.value}-egress-az1"
      https    = local.https
      http     = local.http
      password = local.tfvars.workload_instance_password
      interval = "5"
  })
}

module "gatus_az2" {
  for_each             = toset(local.cps)
  source               = "github.com/aviatrix-internal-only-org/avxlabs-mc-instance"
  name                 = "${each.value}-egress-az2"
  vpc_id               = module.vpc[each.value].vpc_id
  subnet_id            = module.vpc[each.value].private_subnets[1]
  iam_instance_profile = aws_iam_role.ssm.name
  cloud                = "aws"
  instance_size        = "t3.micro"
  public_key           = local.tfvars.ssh_public_key
  password             = local.tfvars.workload_instance_password
  private_ip           = "10.1.${index(local.cps, each.value) + 1}.25"

  user_data_templatefile = templatefile("${path.module}/templates/egress.tpl",
    {
      name     = "${each.value}-egress-az2"
      https    = local.https
      http     = local.http
      password = local.tfvars.workload_instance_password
      interval = "5"
  })
}

module "gatus_az3" {
  for_each             = toset(local.cps)
  source               = "github.com/aviatrix-internal-only-org/avxlabs-mc-instance"
  name                 = "${each.value}-egress-az3"
  vpc_id               = module.vpc[each.value].vpc_id
  subnet_id            = module.vpc[each.value].private_subnets[2]
  iam_instance_profile = aws_iam_role.ssm.name
  cloud                = "aws"
  instance_size        = "t3.micro"
  public_key           = local.tfvars.ssh_public_key
  password             = local.tfvars.workload_instance_password
  private_ip           = "10.1.${index(local.cps, each.value) + 1}.40"

  user_data_templatefile = templatefile("${path.module}/templates/egress.tpl",
    {
      name     = "${each.value}-egress-az3"
      https    = local.https
      http     = local.http
      password = local.tfvars.workload_instance_password
      interval = "5"
  })
}

module "gatus_dashboard" {
  for_each      = toset(local.cps)
  source        = "github.com/aviatrix-internal-only-org/avxlabs-mc-instance?ref=v1.0.9"
  name          = "${each.value}-dashboard"
  vpc_id        = module.vpc[each.value].vpc_id
  subnet_id     = module.vpc[each.value].public_subnets[1]
  cloud         = "aws"
  public_key    = local.tfvars.ssh_public_key
  password      = local.tfvars.workload_instance_password
  instance_size = "t3.micro"
  common_tags   = {}
  public_ip     = true
  inbound_tcp = {
    22 = ["${chomp(data.http.myip.response_body)}/32"]
  }

  user_data_templatefile = templatefile("${path.module}/templates/dashboard.tpl",
    {
      name      = "${each.value}-dashboard"
      gatus     = each.value
      instances = ["${module.gatus_az1[each.value].private_ip}", "${module.gatus_az2[each.value].private_ip}", "${module.gatus_az3[each.value].private_ip}"]
      pwd       = local.tfvars.workload_instance_password
      cloud     = "AWS"
  })
}

module "nginx" {
  source        = "github.com/aviatrix-internal-only-org/avxlabs-mc-instance?ref=v1.0.9"
  name          = "nginx-proxy"
  vpc_id        = module.vpc[local.cps[0]].vpc_id
  subnet_id     = module.vpc[local.cps[0]].public_subnets[1]
  cloud         = "aws"
  public_key    = local.tfvars.ssh_public_key
  password      = local.tfvars.workload_instance_password
  instance_size = "t3.micro"
  common_tags   = {}
  public_ip     = true
  inbound_tcp = {
    22 = ["${chomp(data.http.myip.response_body)}/32"]
  }

  user_data_templatefile = templatefile("${path.module}/templates/nginx.tpl",
    {
      name            = "nginx-proxy"
      marketing       = "${module.az_gatus_dashboard["marketing"].public_ip}"
      engineering     = "${module.az_gatus_dashboard["engineering"].public_ip}"
      accounting      = "${module.az_gatus_dashboard["accounting"].public_ip}"
      operations      = "${module.az_gatus_dashboard["operations"].public_ip}"
      enterprise-data = "${module.az_gatus_dashboard["enterprise-data"].public_ip}"
      pwd             = local.tfvars.workload_instance_password
  })
}
