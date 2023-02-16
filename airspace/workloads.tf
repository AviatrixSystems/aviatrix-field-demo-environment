/*
locals {
  accounting_dev   = cidrhost(cidrsubnet("${trimsuffix(local.transit_firenet.aws_east.transit_cidr, "23")}16", 8, 2), 10)
  accounting_qa    = cidrhost(cidrsubnet("${trimsuffix(local.transit_firenet.aws_east.transit_cidr, "23")}16", 8, 3), 10)
  accounting_prod  = cidrhost(cidrsubnet("${trimsuffix(local.transit_firenet.aws_east.transit_cidr, "23")}16", 8, 4), 10)
  engineering_dev  = cidrhost(cidrsubnet("${trimsuffix(local.transit_firenet.aws_east_2.transit_cidr, "23")}16", 8, 2), 10)
  engineering_qa   = cidrhost(cidrsubnet("${trimsuffix(local.transit_firenet.aws_east_2.transit_cidr, "23")}16", 8, 3), 10)
  engineering_prod = cidrhost(cidrsubnet("${trimsuffix(local.transit_firenet.aws_east_2.transit_cidr, "23")}16", 8, 4), 10)
  marketing_dev    = cidrhost(cidrsubnet("${trimsuffix(local.transit_firenet.azure_germany.transit_cidr, "23")}16", 8, 2), 40)
  marketing_qa     = cidrhost(cidrsubnet("${trimsuffix(local.transit_firenet.azure_germany.transit_cidr, "23")}16", 8, 2), 41)
  marketing_prod   = cidrhost(cidrsubnet("${trimsuffix(local.transit_firenet.azure_germany.transit_cidr, "23")}16", 8, 2), 42)
  operations_dev   = cidrhost(cidrsubnet("${trimsuffix(local.transit_firenet.oci_singapore.transit_cidr, "23")}16", 8, 2), 20)
  operations_qa    = cidrhost(cidrsubnet("${trimsuffix(local.transit_firenet.oci_singapore.transit_cidr, "23")}16", 8, 3), 20)
  operations_prod  = cidrhost(cidrsubnet("${trimsuffix(local.transit_firenet.oci_singapore.transit_cidr, "23")}16", 8, 4), 20)
  sap_dev          = cidrhost(cidrsubnet("${trimsuffix(local.transit_firenet.gcp_west.transit_cidr, "23")}16", 8, 2), 10)
  sap_qa           = cidrhost(cidrsubnet("${trimsuffix(local.transit_firenet.gcp_west.transit_cidr, "23")}16", 8, 3), 10)
  sap_prod_1       = cidrhost(cidrsubnet("${trimsuffix(local.transit_firenet.gcp_west.transit_cidr, "23")}16", 8, 4), 10)
  sap_prod_2       = cidrhost(cidrsubnet("${trimsuffix(local.transit_firenet.gcp_west.transit_cidr, "23")}16", 8, 4), 15)
  external = [
    "aws.amazon.com",
    "stackoverflow.com",
    "go.dev",
    "www.terraform.io",
    "www.wikipedia.org",
    "azure.microsoft.com",
    "cloud.google.com",
    "www.oracle.com/cloud",
    "us.alibabacloud.com",
    "aviatrix.com",
    "www.reddit.com",
    "www.torproject.org"
  ]
  # onprem_host     = cidrhost(local.onprem_cidr, 10)
  # onprem_cidr     = "172.16.0.0/16"
  traffic_gen = {
    accounting_dev = {
      private_ip = local.accounting_dev
      name       = "accounting-app-dev"
      apps = [
        local.engineering_dev, local.engineering_qa, local.engineering_prod,
        local.accounting_dev, local.accounting_qa, local.accounting_prod,
        local.marketing_dev, local.marketing_qa, local.marketing_prod,
        local.operations_dev, local.operations_qa, local.operations_prod,
      ]
      sap      = [local.sap_dev, local.sap_qa, local.sap_prod_1, local.sap_prod_2]
      external = local.external
      interval = "10"
    }
    accounting_qa = {
      private_ip = local.accounting_qa
      name       = "accounting-app-qa"
      apps = [
        local.engineering_dev, local.engineering_qa, local.engineering_prod,
        local.accounting_dev, local.accounting_qa, local.accounting_prod,
        local.marketing_dev, local.marketing_qa, local.marketing_prod,
        local.operations_dev, local.operations_qa, local.operations_prod,
      ]
      sap      = [local.sap_dev, local.sap_qa, local.sap_prod_1, local.sap_prod_2]
      external = local.external
      interval = "15"
    }
    accounting_prod = {
      private_ip = local.accounting_prod
      name       = "accounting-app-prod"
      apps = [
        local.engineering_dev, local.engineering_qa, local.engineering_prod,
        local.accounting_dev, local.accounting_qa, local.accounting_prod,
        local.marketing_dev, local.marketing_qa, local.marketing_prod,
        local.operations_dev, local.operations_qa, local.operations_prod,
      ]
      sap      = [local.sap_dev, local.sap_qa, local.sap_prod_1, local.sap_prod_2]
      external = local.external
      interval = "5"
    }
    engineering_dev = {
      private_ip = local.engineering_dev
      name       = "engineering-app-dev"
      apps = [
        local.engineering_dev, local.engineering_qa, local.engineering_prod,
        local.accounting_dev, local.accounting_qa, local.accounting_prod,
        local.marketing_dev, local.marketing_qa, local.marketing_prod,
        local.operations_dev, local.operations_qa, local.operations_prod,
      ]
      sap      = [local.sap_dev, local.sap_qa, local.sap_prod_1, local.sap_prod_2]
      external = local.external
      interval = "10"
    }
    engineering_qa = {
      private_ip = local.engineering_qa
      name       = "engineering-app-qa"
      apps = [
        local.engineering_dev, local.engineering_qa, local.engineering_prod,
        local.accounting_dev, local.accounting_qa, local.accounting_prod,
        local.marketing_dev, local.marketing_qa, local.marketing_prod,
        local.operations_dev, local.operations_qa, local.operations_prod,
      ]
      sap      = [local.sap_dev, local.sap_qa, local.sap_prod_1, local.sap_prod_2]
      external = local.external
      interval = "15"
    }
    engineering_prod = {
      private_ip = local.engineering_prod
      name       = "engineering-app-prod"
      apps = [
        local.engineering_dev, local.engineering_qa, local.engineering_prod,
        local.accounting_dev, local.accounting_qa, local.accounting_prod,
        local.marketing_dev, local.marketing_qa, local.marketing_prod,
        local.operations_dev, local.operations_qa, local.operations_prod,
      ]
      sap      = [local.sap_dev, local.sap_qa, local.sap_prod_1, local.sap_prod_2]
      external = local.external
      interval = "5"
    }
    marketing_dev = {
      private_ip = local.marketing_dev
      name       = "marketing-app-dev"
      apps = [
        local.engineering_dev, local.engineering_qa, local.engineering_prod,
        local.accounting_dev, local.accounting_qa, local.accounting_prod,
        local.marketing_dev, local.marketing_qa, local.marketing_prod,
        local.operations_dev, local.operations_qa, local.operations_prod,
      ]
      sap      = [local.sap_dev, local.sap_qa, local.sap_prod_1, local.sap_prod_2]
      external = local.external
      interval = "10"
    }
    marketing_qa = {
      private_ip = local.marketing_qa
      name       = "marketing-app-qa"
      apps = [
        local.engineering_dev, local.engineering_qa, local.engineering_prod,
        local.accounting_dev, local.accounting_qa, local.accounting_prod,
        local.marketing_dev, local.marketing_qa, local.marketing_prod,
        local.operations_dev, local.operations_qa, local.operations_prod,
      ]
      sap      = [local.sap_dev, local.sap_qa, local.sap_prod_1, local.sap_prod_2]
      external = local.external
      interval = "15"
    }
    marketing_prod = {
      private_ip = local.marketing_prod
      name       = "marketing-app-prod"
      apps = [
        local.engineering_dev, local.engineering_qa, local.engineering_prod,
        local.accounting_dev, local.accounting_qa, local.accounting_prod,
        local.marketing_dev, local.marketing_qa, local.marketing_prod,
        local.operations_dev, local.operations_qa, local.operations_prod,
      ]
      sap      = [local.sap_dev, local.sap_qa, local.sap_prod_1, local.sap_prod_2]
      external = local.external
      interval = "5"
    }
    operations_dev = {
      private_ip = local.operations_dev
      name       = "operations-app-dev"
      apps = [
        local.engineering_dev, local.engineering_qa, local.engineering_prod,
        local.accounting_dev, local.accounting_qa, local.accounting_prod,
        local.marketing_dev, local.marketing_qa, local.marketing_prod,
        local.operations_dev, local.operations_qa, local.operations_prod,
      ]
      sap      = [local.sap_dev, local.sap_qa, local.sap_prod_1, local.sap_prod_2]
      external = local.external
      interval = "10"
    }
    operations_qa = {
      private_ip = local.operations_qa
      name       = "operations-app-qa"
      apps = [
        local.engineering_dev, local.engineering_qa, local.engineering_prod,
        local.accounting_dev, local.accounting_qa, local.accounting_prod,
        local.marketing_dev, local.marketing_qa, local.marketing_prod,
        local.operations_dev, local.operations_qa, local.operations_prod,
      ]
      sap      = [local.sap_dev, local.sap_qa, local.sap_prod_1, local.sap_prod_2]
      external = local.external
      interval = "15"
    }
    operations_prod = {
      private_ip = local.operations_prod
      name       = "operations-app-prod"
      apps = [
        local.engineering_dev, local.engineering_qa, local.engineering_prod,
        local.accounting_dev, local.accounting_qa, local.accounting_prod,
        local.marketing_dev, local.marketing_qa, local.marketing_prod,
        local.operations_dev, local.operations_qa, local.operations_prod,
      ]
      sap      = [local.sap_dev, local.sap_qa, local.sap_prod_1, local.sap_prod_2]
      external = local.external
      interval = "5"
    }
    sap_dev = {
      private_ip = local.sap_dev
      name       = "sap-shared-dev"
    }
    sap_qa = {
      private_ip = local.sap_qa
      name       = "sap-shared-qa"
    }
    sap_prod_1 = {
      private_ip = local.sap_prod_1
      name       = "sap-shared-prod-1"
    }
    sap_prod_2 = {
      private_ip = local.sap_prod_2
      name       = "sap-shared-prod-2"
    }
  }
}
*/
module "accounting_dev" {
  source               = "./mc-instance"
  vpc_id               = module.spoke_1["aws_east"].vpc.vpc_id
  subnet_id            = module.spoke_1["aws_east"].vpc.private_subnets[0].subnet_id
  key_name             = var.key_name
  cloud                = local.transit_firenet.aws_east.transit_cloud
  traffic_gen          = local.traffic_gen.accounting_dev
  iam_instance_profile = aws_iam_instance_profile.ec2_role_for_ssm.name
  common_tags = merge(var.common_tags, {
    Department  = "Accounting"
    Cloud       = "AWS"
    Application = "CRM"
    Environment = "Dev"
  })
  workload_password = var.workload_password
}

# module "accounting_qa" {
#   source               = "./mc-instance"
#   vpc_id               = module.spoke_2["aws_east"].vpc.vpc_id
#   subnet_id            = module.spoke_2["aws_east"].vpc.private_subnets[0].subnet_id
#   key_name             = var.key_name
#   cloud                = local.transit_firenet.aws_east.transit_cloud
#   traffic_gen          = local.traffic_gen.accounting_qa
#   iam_instance_profile = aws_iam_instance_profile.ec2_role_for_ssm.name
#   common_tags = merge(var.common_tags, {
#     Department  = "Accounting"
#     Application = "CRM"
#     Environment = "QA"
#   })
#   workload_password = var.workload_password
# }

# module "accounting_prod" {
#   source               = "./mc-instance"
#   vpc_id               = module.spoke_3["aws_east"].vpc.vpc_id
#   subnet_id            = module.spoke_3["aws_east"].vpc.private_subnets[0].subnet_id
#   key_name             = var.key_name
#   cloud                = local.transit_firenet.aws_east.transit_cloud
#   traffic_gen          = local.traffic_gen.accounting_prod
#   iam_instance_profile = aws_iam_instance_profile.ec2_role_for_ssm.name
#   common_tags = merge(var.common_tags, {
#     Department  = "Accounting"
#     Application = "CRM"
#     Environment = "Prod"
#   })
#   workload_password = var.workload_password
# }

# module "engineering_dev" {
#   source               = "./mc-instance"
#   vpc_id               = module.spoke_1["aws_east_2"].vpc.vpc_id
#   subnet_id            = module.spoke_1["aws_east_2"].vpc.private_subnets[0].subnet_id
#   key_name             = var.key_name
#   cloud                = local.transit_firenet.aws_east_2.transit_cloud
#   traffic_gen          = local.traffic_gen.engineering_dev
#   iam_instance_profile = aws_iam_instance_profile.ec2_role_for_ssm.name
#   common_tags = merge(var.common_tags, {
#     Department  = "Engineering"
#     Application = "Engineering App"
#     Environment = "Dev"
#   })
#   workload_password = var.workload_password
#   providers = {
#     aws = aws.us-east-2
#   }
# }

# module "engineering_qa" {
#   source               = "./mc-instance"
#   vpc_id               = module.spoke_2["aws_east_2"].vpc.vpc_id
#   subnet_id            = module.spoke_2["aws_east_2"].vpc.private_subnets[0].subnet_id
#   key_name             = var.key_name
#   cloud                = local.transit_firenet.aws_east_2.transit_cloud
#   traffic_gen          = local.traffic_gen.engineering_qa
#   iam_instance_profile = aws_iam_instance_profile.ec2_role_for_ssm.name
#   common_tags = merge(var.common_tags, {
#     Department  = "Engineering"
#     Application = "Engineering App"
#     Environment = "QA"
#   })
#   workload_password = var.workload_password
#   providers = {
#     aws = aws.us-east-2
#   }
# }

# module "engineering_prod" {
#   source               = "./mc-instance"
#   vpc_id               = module.spoke_3["aws_east_2"].vpc.vpc_id
#   subnet_id            = module.spoke_3["aws_east_2"].vpc.private_subnets[0].subnet_id
#   key_name             = var.key_name
#   cloud                = local.transit_firenet.aws_east_2.transit_cloud
#   traffic_gen          = local.traffic_gen.engineering_prod
#   iam_instance_profile = aws_iam_instance_profile.ec2_role_for_ssm.name
#   common_tags = merge(var.common_tags, {
#     Department  = "Engineering"
#     Application = "Engineering App"
#     Environment = "Prod"
#   })
#   workload_password = var.workload_password
#   providers = {
#     aws = aws.us-east-2
#   }
# }

# module "marketing_dev" {
#   source         = "./mc-instance"
#   resource_group = module.spoke_1["azure_germany"].vpc.resource_group
#   subnet_id      = module.spoke_1["azure_germany"].vpc.private_subnets[0].subnet_id
#   location       = local.transit_firenet.azure_germany.transit_region_name
#   cloud          = local.transit_firenet.azure_germany.transit_cloud
#   traffic_gen    = local.traffic_gen.marketing_dev
#   common_tags = merge(var.common_tags, {
#     Department  = "Marketing"
#     Application = "Marketing App"
#     Environment = "Dev"
#   })
#   workload_password = var.workload_password
# }

# module "marketing_qa" {
#   source         = "./mc-instance"
#   resource_group = module.spoke_1["azure_germany"].vpc.resource_group
#   subnet_id      = module.spoke_1["azure_germany"].vpc.private_subnets[0].subnet_id
#   location       = local.transit_firenet.azure_germany.transit_region_name
#   cloud          = local.transit_firenet.azure_germany.transit_cloud
#   traffic_gen    = local.traffic_gen.marketing_qa
#   common_tags = merge(var.common_tags, {
#     Department  = "Marketing"
#     Application = "Marketing App"
#     Environment = "QA"
#   })
#   workload_password = var.workload_password
# }

# module "marketing_prod" {
#   source         = "./mc-instance"
#   resource_group = module.spoke_1["azure_germany"].vpc.resource_group
#   subnet_id      = module.spoke_1["azure_germany"].vpc.private_subnets[0].subnet_id
#   location       = local.transit_firenet.azure_germany.transit_region_name
#   cloud          = local.transit_firenet.azure_germany.transit_cloud
#   traffic_gen    = local.traffic_gen.marketing_prod
#   common_tags = merge(var.common_tags, {
#     Department  = "Marketing"
#     Application = "Marketing App"
#     Environment = "Prod"
#   })
#   workload_password = var.workload_password
# }

# module "operations_dev" {
#   source               = "./mc-instance"
#   oci_compartment_ocid = var.oci_compartment_ocid
#   subnet_id            = module.spoke_1["oci_singapore"].vpc.private_subnets[0].subnet_id
#   cloud                = local.transit_firenet.oci_singapore.transit_cloud
#   traffic_gen          = local.traffic_gen.operations_dev
#   common_tags = merge(var.common_tags, {
#     Department  = "Operations"
#     Application = "Operations App"
#     Environment = "Dev"
#   })
#   workload_password = var.workload_password
# }

# module "operations_qa" {
#   source               = "./mc-instance"
#   oci_compartment_ocid = var.oci_compartment_ocid
#   subnet_id            = module.spoke_2["oci_singapore"].vpc.private_subnets[0].subnet_id
#   cloud                = local.transit_firenet.oci_singapore.transit_cloud
#   traffic_gen          = local.traffic_gen.operations_qa
#   common_tags = merge(var.common_tags, {
#     Department  = "Operations"
#     Application = "Operations App"
#     Environment = "QA"
#   })
#   workload_password = var.workload_password
# }

# module "operations_prod" {
#   source               = "./mc-instance"
#   oci_compartment_ocid = var.oci_compartment_ocid
#   subnet_id            = module.spoke_3["oci_singapore"].vpc.private_subnets[0].subnet_id
#   cloud                = local.transit_firenet.oci_singapore.transit_cloud
#   traffic_gen          = local.traffic_gen.operations_prod
#   common_tags = merge(var.common_tags, {
#     Department  = "Operations"
#     Application = "Operations App"
#     Environment = "Prod"
#   })
#   workload_password = var.workload_password
# }

# module "sap_dev" {
#   source      = "./mc-instance"
#   vpc_id      = module.spoke_1["gcp_west"].vpc.name
#   subnet_id   = module.spoke_1["gcp_west"].vpc.subnets[0].name
#   cloud       = local.transit_firenet.gcp_west.transit_cloud
#   region      = local.transit_firenet.gcp_west.transit_region_name
#   traffic_gen = local.traffic_gen.sap_dev
#   common_tags = merge(var.common_tags, {
#     Department  = "Shared Services"
#     Application = "SAP"
#     Environment = "Dev"
#   })
#   workload_password = var.workload_password
# }

# module "sap_qa" {
#   source      = "./mc-instance"
#   vpc_id      = module.spoke_2["gcp_west"].vpc.name
#   subnet_id   = module.spoke_2["gcp_west"].vpc.subnets[0].name
#   cloud       = local.transit_firenet.gcp_west.transit_cloud
#   region      = local.transit_firenet.gcp_west.transit_region_name
#   traffic_gen = local.traffic_gen.sap_qa
#   common_tags = merge(var.common_tags, {
#     Department  = "Shared Services"
#     Application = "SAP"
#     Environment = "QA"
#   })
#   workload_password = var.workload_password
# }

# module "sap_prod_1" {
#   source      = "./mc-instance"
#   vpc_id      = module.spoke_3["gcp_west"].vpc.name
#   subnet_id   = module.spoke_3["gcp_west"].vpc.subnets[0].name
#   cloud       = local.transit_firenet.gcp_west.transit_cloud
#   region      = local.transit_firenet.gcp_west.transit_region_name
#   traffic_gen = local.traffic_gen.sap_prod_1
#   common_tags = merge(var.common_tags, {
#     Department  = "Shared Services"
#     Application = "SAP"
#     Environment = "Prod"
#   })
#   workload_password = var.workload_password
# }

# module "sap_prod_2" {
#   source      = "./mc-instance"
#   vpc_id      = module.spoke_3["gcp_west"].vpc.name
#   subnet_id   = module.spoke_3["gcp_west"].vpc.subnets[0].name
#   cloud       = local.transit_firenet.gcp_west.transit_cloud
#   region      = local.transit_firenet.gcp_west.transit_region_name
#   traffic_gen = local.traffic_gen.sap_prod_2
#   common_tags = merge(var.common_tags, {
#     Department  = "Shared Services"
#     Application = "SAP"
#     Environment = "Prod"
#   })
#   workload_password = var.workload_password
# }
