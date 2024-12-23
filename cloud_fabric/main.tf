# https://registry.terraform.io/modules/terraform-aviatrix-modules/backbone/aviatrix/latest
module "backbone" {
  source  = "terraform-aviatrix-modules/backbone/aviatrix"
  version = "v1.3.1"
  global_settings = {
    transit_accounts = {
      aws   = var.aws_operations_account_name,
      azure = var.azure_operations_account_name,
      gcp   = var.gcp_operations_account_name,
      oci   = var.oci_operations_account_name,
    }
    transit_ha_gw = false
  }
  transit_firenet = local.backbone
}

# https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-spoke/aviatrix/latest
module "spokes" {
  for_each = { for spoke in local.regional_spokes : "${spoke.avx_account}-${spoke.spoke}" => spoke }
  source   = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version  = "1.7.0"

  cloud          = each.value.cloud
  name           = "${each.value.avx_account}-spoke-${each.value.spoke}"
  cidr           = each.value.spoke == "qa" ? cidrsubnet("${trimsuffix(each.value.transit_cidr, "23")}16", 8, 3) : each.value.spoke == "prod" ? cidrsubnet("${trimsuffix(each.value.transit_cidr, "23")}16", 8, 4) : cidrsubnet("${trimsuffix(each.value.transit_cidr, "23")}16", 8, 2)
  region         = each.value.region
  account        = each.value.avx_account
  subnet_pairs   = each.value.cloud == "azure" ? 3 : null
  instance_size  = each.value.cloud == "aws" ? "t3.medium" : each.value.cloud == "gcp" ? "n1-standard-2" : each.value.cloud == "azure" ? "Standard_B2ms" : each.value.cloud == "oci" ? "VM.Standard2.2" : each.value.cloud == "ali" ? "ecs.g5ne.large" : null
  transit_gw     = module.backbone.transit["${each.value.cloud}_${replace(lower(each.value.region), "/[ -]/", "_")}"].transit_gateway.gw_name
  ha_gw          = false
  attached       = true
  single_ip_snat = true
  insane_mode    = strcontains(each.key, "engineering-aws") ? true : false
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
