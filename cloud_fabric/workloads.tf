data "aws_route53_zone" "demo" {
  name         = "demo.aviatrixtest.com"
  private_zone = false
}

module "accounting_dev" {
  source     = "./mc-instance"
  name       = local.traffic_gen.accounting_dev.name
  vpc_id     = module.spokes["${var.aws_accounting_account_name}-dev"].vpc.vpc_id
  subnet_id  = module.spokes["${var.aws_accounting_account_name}-dev"].vpc.private_subnets[0].subnet_id
  cloud      = "aws"
  public_key = var.public_key
  password   = var.workload_instance_password
  private_ip = local.traffic_gen.accounting_dev.private_ip
  common_tags = merge(var.common_tags, {
    Department  = "accounting"
    Application = "crm"
    Environment = "dev"
  })

  user_data_templatefile = templatefile("${var.workload_template_path}/gatus.tpl",
    {
      name     = local.traffic_gen.accounting_dev.name
      domain   = "demo.aviatrixtest.com"
      password = var.workload_instance_password
      apps     = join(",", setsubtract(local.all_workloads, [local.traffic_gen.accounting_dev.name]))
      external = join(",", local.external)
      interval = local.traffic_gen.accounting_dev.interval
  })
  depends_on = [module.spokes]
  providers = {
    aws = aws.accounting
  }
}

resource "aws_route53_record" "accounting_dev" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "${local.traffic_gen.accounting_dev.name}.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [local.traffic_gen.accounting_dev.private_ip]
}

module "accounting_qa" {
  source     = "./mc-instance"
  name       = local.traffic_gen.accounting_qa.name
  vpc_id     = module.spokes["${var.aws_accounting_account_name}-qa"].vpc.vpc_id
  subnet_id  = module.spokes["${var.aws_accounting_account_name}-qa"].vpc.private_subnets[0].subnet_id
  cloud      = "aws"
  public_key = var.public_key
  password   = var.workload_instance_password
  private_ip = local.traffic_gen.accounting_qa.private_ip
  common_tags = merge(var.common_tags, {
    Department  = "accounting"
    Application = "crm"
    Environment = "qa"
  })

  user_data_templatefile = templatefile("${var.workload_template_path}/gatus.tpl",
    {
      name     = local.traffic_gen.accounting_qa.name
      domain   = "demo.aviatrixtest.com"
      password = var.workload_instance_password
      apps     = join(",", setsubtract(local.all_workloads, [local.traffic_gen.accounting_qa.name]))
      external = join(",", local.external)
      interval = local.traffic_gen.accounting_qa.interval
  })
  providers = {
    aws = aws.accounting
  }
  depends_on = [module.spokes]
}

resource "aws_route53_record" "accounting_qa" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "${local.traffic_gen.accounting_qa.name}.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [local.traffic_gen.accounting_qa.private_ip]
}

module "accounting_prod" {
  source     = "./mc-instance"
  name       = local.traffic_gen.accounting_prod.name
  vpc_id     = module.spokes["${var.aws_accounting_account_name}-prod"].vpc.vpc_id
  subnet_id  = module.spokes["${var.aws_accounting_account_name}-prod"].vpc.private_subnets[0].subnet_id
  cloud      = "aws"
  public_key = var.public_key
  password   = var.workload_instance_password
  private_ip = local.traffic_gen.accounting_prod.private_ip
  common_tags = merge(var.common_tags, {
    Department  = "accounting"
    Application = "crm"
    Environment = "prod"
  })

  user_data_templatefile = templatefile("${var.workload_template_path}/gatus.tpl",
    {
      name     = local.traffic_gen.accounting_prod.name
      domain   = "demo.aviatrixtest.com"
      password = var.workload_instance_password
      apps     = join(",", setsubtract(local.all_workloads, [local.traffic_gen.accounting_prod.name]))
      external = join(",", local.external)
      interval = local.traffic_gen.accounting_prod.interval
  })
  providers = {
    aws = aws.accounting
  }
  depends_on = [module.spokes]
}

resource "aws_route53_record" "accounting_prod" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "${local.traffic_gen.accounting_prod.name}.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [local.traffic_gen.accounting_prod.private_ip]
}

module "engineering_dev" {
  source     = "./mc-instance"
  name       = local.traffic_gen.engineering_dev.name
  vpc_id     = module.spokes["${var.aws_engineering_account_name}-dev"].vpc.vpc_id
  subnet_id  = module.spokes["${var.aws_engineering_account_name}-dev"].vpc.private_subnets[0].subnet_id
  cloud      = "aws"
  public_key = var.public_key
  password   = var.workload_instance_password
  private_ip = local.traffic_gen.engineering_dev.private_ip
  common_tags = merge(var.common_tags, {
    Department  = "engineering"
    Application = "engineering app"
    Environment = "dev"
  })

  user_data_templatefile = templatefile("${var.workload_template_path}/gatus.tpl",
    {
      name     = local.traffic_gen.engineering_dev.name
      domain   = "demo.aviatrixtest.com"
      password = var.workload_instance_password
      apps     = join(",", setsubtract(local.all_workloads, [local.traffic_gen.engineering_dev.name]))
      external = join(",", local.external)
      interval = local.traffic_gen.engineering_dev.interval
  })
  depends_on = [module.spokes]
  providers = {
    aws = aws.engineering
  }
}

resource "aws_route53_record" "engineering_dev" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "${local.traffic_gen.engineering_dev.name}.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [local.traffic_gen.engineering_dev.private_ip]
}

module "engineering_qa" {
  source     = "./mc-instance"
  name       = local.traffic_gen.engineering_qa.name
  vpc_id     = module.spokes["${var.aws_engineering_account_name}-qa"].vpc.vpc_id
  subnet_id  = module.spokes["${var.aws_engineering_account_name}-qa"].vpc.private_subnets[0].subnet_id
  cloud      = "aws"
  public_key = var.public_key
  password   = var.workload_instance_password
  private_ip = local.traffic_gen.engineering_qa.private_ip
  common_tags = merge(var.common_tags, {
    Department  = "engineering"
    Application = "engineering app"
    Environment = "qa"
  })

  user_data_templatefile = templatefile("${var.workload_template_path}/gatus.tpl",
    {
      name     = local.traffic_gen.engineering_qa.name
      domain   = "demo.aviatrixtest.com"
      password = var.workload_instance_password
      apps     = join(",", setsubtract(local.all_workloads, [local.traffic_gen.accounting_qa.name]))
      external = join(",", local.external)
      interval = local.traffic_gen.engineering_qa.interval
  })
  depends_on = [module.spokes]
  providers = {
    aws = aws.engineering
  }
}

resource "aws_route53_record" "engineering_qa" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "${local.traffic_gen.engineering_qa.name}.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [local.traffic_gen.engineering_qa.private_ip]
}

module "engineering_prod" {
  source     = "./mc-instance"
  name       = local.traffic_gen.engineering_prod.name
  vpc_id     = module.spokes["${var.aws_engineering_account_name}-prod"].vpc.vpc_id
  subnet_id  = module.spokes["${var.aws_engineering_account_name}-prod"].vpc.private_subnets[0].subnet_id
  cloud      = "aws"
  public_key = var.public_key
  password   = var.workload_instance_password
  private_ip = local.traffic_gen.engineering_prod.private_ip
  common_tags = merge(var.common_tags, {
    Department  = "engineering"
    Application = "engineering app"
    Environment = "prod"
  })

  user_data_templatefile = templatefile("${var.workload_template_path}/gatus.tpl",
    {
      name     = local.traffic_gen.engineering_prod.name
      domain   = "demo.aviatrixtest.com"
      password = var.workload_instance_password
      apps     = join(",", setsubtract(local.all_workloads, [local.traffic_gen.engineering_prod.name]))
      external = join(",", local.external)
      interval = local.traffic_gen.engineering_prod.interval
  })
  depends_on = [module.spokes]
  providers = {
    aws = aws.engineering
  }
}

resource "aws_route53_record" "engineering_prod" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "${local.traffic_gen.engineering_prod.name}.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [local.traffic_gen.engineering_prod.private_ip]
}

module "marketing_dev" {
  source         = "./mc-instance"
  cloud          = "azure"
  name           = local.traffic_gen.marketing_dev.name
  resource_group = module.spokes["${var.azure_marketing_account_name}-all"].vpc.resource_group
  subnet_id      = module.spokes["${var.azure_marketing_account_name}-all"].vpc.private_subnets[0].subnet_id
  location       = module.spokes["${var.azure_marketing_account_name}-all"].vpc.region
  password       = var.workload_instance_password
  private_ip     = local.traffic_gen.marketing_dev.private_ip
  common_tags = merge(var.common_tags, {
    Department  = "marketing"
    Application = "marketing app"
    Environment = "dev"
  })

  user_data_templatefile = templatefile("${var.workload_template_path}/gatus.tpl",
    {
      name     = local.traffic_gen.marketing_dev.name
      domain   = "demo.aviatrixtest.com"
      password = var.workload_instance_password
      apps     = join(",", setsubtract(local.all_workloads, [local.traffic_gen.marketing_dev.name]))
      external = join(",", local.external)
      interval = local.traffic_gen.marketing_dev.interval
  })
  depends_on = [module.spokes]
}

resource "aws_route53_record" "marketing_dev" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "${local.traffic_gen.marketing_dev.name}.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [local.traffic_gen.marketing_dev.private_ip]
}

module "marketing_qa" {
  source         = "./mc-instance"
  cloud          = "azure"
  name           = local.traffic_gen.marketing_qa.name
  resource_group = module.spokes["${var.azure_marketing_account_name}-all"].vpc.resource_group
  subnet_id      = module.spokes["${var.azure_marketing_account_name}-all"].vpc.private_subnets[1].subnet_id
  location       = module.spokes["${var.azure_marketing_account_name}-all"].vpc.region
  password       = var.workload_instance_password
  private_ip     = local.traffic_gen.marketing_qa.private_ip
  common_tags = merge(var.common_tags, {
    Department  = "marketing"
    Application = "marketing app"
    Environment = "qa"
  })

  user_data_templatefile = templatefile("${var.workload_template_path}/gatus.tpl",
    {
      name     = local.traffic_gen.marketing_qa.name
      domain   = "demo.aviatrixtest.com"
      password = var.workload_instance_password
      apps     = join(",", setsubtract(local.all_workloads, [local.traffic_gen.marketing_qa.name]))
      external = join(",", local.external)
      interval = local.traffic_gen.marketing_qa.interval
  })
  depends_on = [module.spokes]
}

resource "aws_route53_record" "marketing_qa" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "${local.traffic_gen.marketing_qa.name}.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [local.traffic_gen.marketing_qa.private_ip]
}

module "marketing_prod" {
  source         = "./mc-instance"
  cloud          = "azure"
  name           = local.traffic_gen.marketing_prod.name
  resource_group = module.spokes["${var.azure_marketing_account_name}-all"].vpc.resource_group
  subnet_id      = module.spokes["${var.azure_marketing_account_name}-all"].vpc.private_subnets[2].subnet_id
  location       = module.spokes["${var.azure_marketing_account_name}-all"].vpc.region
  password       = var.workload_instance_password
  private_ip     = local.traffic_gen.marketing_prod.private_ip
  common_tags = merge(var.common_tags, {
    Department  = "marketing"
    Application = "marketing app"
    Environment = "prod"
  })

  user_data_templatefile = templatefile("${var.workload_template_path}/gatus.tpl",
    {
      name     = local.traffic_gen.marketing_prod.name
      domain   = "demo.aviatrixtest.com"
      password = var.workload_instance_password
      apps     = join(",", setsubtract(local.all_workloads, [local.traffic_gen.marketing_prod.name]))
      external = join(",", local.external)
      interval = local.traffic_gen.marketing_prod.interval
  })
  depends_on = [module.spokes]
}

resource "aws_route53_record" "marketing_prod" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "${local.traffic_gen.marketing_prod.name}.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [local.traffic_gen.marketing_prod.private_ip]
}

module "operations_shared" {
  source               = "./mc-instance"
  cloud                = "oci"
  name                 = local.traffic_gen.operations_shared.name
  oci_compartment_ocid = var.oci_operations_compartment_ocid
  oci_vcn_ocid         = module.spokes["${var.oci_operations_account_name}-shared"].vpc.vpc_id
  subnet_id            = module.spokes["${var.oci_operations_account_name}-shared"].vpc.private_subnets[0].subnet_id
  password             = var.workload_instance_password
  private_ip           = local.traffic_gen.operations_shared.private_ip
  common_tags = merge(var.common_tags, {
    Department  = "operations"
    Application = "shared"
    Environment = "shared"
  })

  user_data_templatefile = templatefile("${var.workload_template_path}/oci.tpl",
    {
      name     = local.traffic_gen.operations_shared.name
      domain   = "demo.aviatrixtest.com"
      password = var.workload_instance_password
  })
  depends_on = [module.spokes]
}

resource "aws_route53_record" "operations_shared" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "${local.traffic_gen.operations_shared.name}.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [local.traffic_gen.operations_shared.private_ip]
}

module "enterprise_data_dev" {
  source     = "./mc-instance"
  cloud      = "gcp"
  name       = local.traffic_gen.enterprise_data_dev.name
  vpc_id     = module.spokes["${var.gcp_enterprise_data_account_name}-dev"].vpc.name
  subnet_id  = module.spokes["${var.gcp_enterprise_data_account_name}-dev"].vpc.subnets[0].name
  region     = module.spokes["${var.gcp_enterprise_data_account_name}-dev"].vpc.subnets[0].region
  password   = var.workload_instance_password
  private_ip = local.traffic_gen.enterprise_data_dev.private_ip
  common_tags = merge(var.common_tags, {
    Department  = "enterprise data"
    Application = "data"
    Environment = "dev-data"
  })

  user_data_templatefile = templatefile("${var.workload_template_path}/gcp.tpl",
    {
      name     = local.traffic_gen.enterprise_data_dev.name
      domain   = "demo.aviatrixtest.com"
      password = var.workload_instance_password
  })
  depends_on = [module.spokes]
}

resource "aws_route53_record" "enterprise_data_dev" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "${local.traffic_gen.enterprise_data_dev.name}.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [local.traffic_gen.enterprise_data_dev.private_ip]
}

module "enterprise_data_qa" {
  source     = "./mc-instance"
  cloud      = "gcp"
  name       = local.traffic_gen.enterprise_data_qa.name
  vpc_id     = module.spokes["${var.gcp_enterprise_data_account_name}-qa"].vpc.name
  subnet_id  = module.spokes["${var.gcp_enterprise_data_account_name}-qa"].vpc.subnets[0].name
  region     = module.spokes["${var.gcp_enterprise_data_account_name}-qa"].vpc.subnets[0].region
  password   = var.workload_instance_password
  private_ip = local.traffic_gen.enterprise_data_qa.private_ip
  common_tags = merge(var.common_tags, {
    Department  = "enterprise data"
    Application = "data"
    Environment = "qa-data"
  })

  user_data_templatefile = templatefile("${var.workload_template_path}/gcp.tpl",
    {
      name     = local.traffic_gen.enterprise_data_qa.name
      domain   = "demo.aviatrixtest.com"
      password = var.workload_instance_password
  })
  depends_on = [module.spokes]
}

resource "aws_route53_record" "enterprise_data_qa" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "${local.traffic_gen.enterprise_data_qa.name}.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [local.traffic_gen.enterprise_data_qa.private_ip]
}

module "enterprise_data_prod" {
  source     = "./mc-instance"
  cloud      = "gcp"
  name       = local.traffic_gen.enterprise_data_prod.name
  vpc_id     = module.spokes["${var.gcp_enterprise_data_account_name}-prod"].vpc.name
  subnet_id  = module.spokes["${var.gcp_enterprise_data_account_name}-prod"].vpc.subnets[0].name
  region     = module.spokes["${var.gcp_enterprise_data_account_name}-prod"].vpc.subnets[0].region
  password   = var.workload_instance_password
  private_ip = local.traffic_gen.enterprise_data_prod.private_ip
  common_tags = merge(var.common_tags, {
    Department  = "enterprise data"
    Application = "data"
    Environment = "prod-data"
  })

  user_data_templatefile = templatefile("${var.workload_template_path}/gcp.tpl",
    {
      name     = local.traffic_gen.enterprise_data_prod.name
      domain   = "demo.aviatrixtest.com"
      password = var.workload_instance_password
  })
  depends_on = [module.spokes]
}

resource "aws_route53_record" "enterprise_data_prod" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "${local.traffic_gen.enterprise_data_prod.name}.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [local.traffic_gen.enterprise_data_prod.private_ip]
}
