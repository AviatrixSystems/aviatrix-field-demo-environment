# Network domains
resource "aviatrix_segmentation_network_domain" "dev" {
  domain_name = "Dev"
}

resource "aviatrix_segmentation_network_domain" "qa" {
  domain_name = "QA"
}

resource "aviatrix_segmentation_network_domain" "prod" {
  domain_name = "Prod"
}

resource "aviatrix_segmentation_network_domain" "azure" {
  domain_name = "Azure"
}

resource "aviatrix_segmentation_network_domain" "edge" {
  domain_name = "Edge"
}

resource "aviatrix_segmentation_network_domain" "shared" {
  domain_name = "Shared"
}

resource "aviatrix_segmentation_network_domain" "onprem" {
  domain_name = "Onprem"
}

# Connections policies
resource "aviatrix_segmentation_network_domain_connection_policy" "onprem_azure" {
  domain_name_1 = aviatrix_segmentation_network_domain.onprem.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.azure.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "onprem_dev" {
  domain_name_1 = aviatrix_segmentation_network_domain.onprem.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.dev.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "onprem_qa" {
  domain_name_1 = aviatrix_segmentation_network_domain.onprem.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.qa.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "onprem_prod" {
  domain_name_1 = aviatrix_segmentation_network_domain.onprem.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.prod.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "shared_onprem" {
  domain_name_1 = aviatrix_segmentation_network_domain.shared.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.onprem.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "edge_dev" {
  domain_name_1 = aviatrix_segmentation_network_domain.edge.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.dev.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "edge_qa" {
  domain_name_1 = aviatrix_segmentation_network_domain.edge.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.qa.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "edge_prod" {
  domain_name_1 = aviatrix_segmentation_network_domain.edge.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.prod.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "shared_edge" {
  domain_name_1 = aviatrix_segmentation_network_domain.shared.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.edge.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "shared_dev" {
  domain_name_1 = aviatrix_segmentation_network_domain.shared.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.dev.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "share_qa" {
  domain_name_1 = aviatrix_segmentation_network_domain.shared.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.qa.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "shared_prod" {
  domain_name_1 = aviatrix_segmentation_network_domain.shared.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.prod.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "shared_azure" {
  domain_name_1 = aviatrix_segmentation_network_domain.shared.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.azure.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "azure_edge" {
  domain_name_1 = aviatrix_segmentation_network_domain.azure.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.edge.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "azure_dev" {
  domain_name_1 = aviatrix_segmentation_network_domain.azure.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.dev.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "azure_qa" {
  domain_name_1 = aviatrix_segmentation_network_domain.azure.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.qa.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "azure_prod" {
  domain_name_1 = aviatrix_segmentation_network_domain.azure.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.prod.domain_name
}

# # Associations
resource "aviatrix_segmentation_network_domain_association" "edge" {
  network_domain_name = aviatrix_segmentation_network_domain.edge.domain_name
  attachment_name     = "${local.edge_prefix}-edge-site"
  depends_on          = [module.edge]
}

resource "aviatrix_segmentation_network_domain_association" "azure" {
  transit_gateway_name = module.backbone.transit["azure_${replace(lower(var.transit_azure_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  network_domain_name  = aviatrix_segmentation_network_domain.azure.domain_name
  attachment_name      = module.spokes["${var.azure_marketing_account_name}-all"].spoke_gateway.gw_name
}

resource "aviatrix_segmentation_network_domain_association" "shared" {
  transit_gateway_name = module.backbone.transit["oci_${replace(lower(var.transit_oci_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  network_domain_name  = aviatrix_segmentation_network_domain.shared.domain_name
  attachment_name      = module.spokes["${var.oci_operations_account_name}-shared"].spoke_gateway.gw_name
}

resource "aviatrix_segmentation_network_domain_association" "dev_aws_east_1" {
  transit_gateway_name = module.backbone.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  network_domain_name  = aviatrix_segmentation_network_domain.dev.domain_name
  attachment_name      = module.spokes["${var.aws_accounting_account_name}-dev"].spoke_gateway.gw_name
}

resource "aviatrix_segmentation_network_domain_association" "dev_aws_east_2" {
  transit_gateway_name = module.backbone.transit["aws_${replace(lower(var.transit_aws_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  network_domain_name  = aviatrix_segmentation_network_domain.dev.domain_name
  attachment_name      = module.spokes["${var.aws_engineering_account_name}-dev"].spoke_gateway.gw_name
}

resource "aviatrix_segmentation_network_domain_association" "dev_gcp" {
  transit_gateway_name = module.backbone.transit["gcp_${replace(lower(var.transit_gcp_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  network_domain_name  = aviatrix_segmentation_network_domain.dev.domain_name
  attachment_name      = module.spokes["${var.gcp_enterprise_data_account_name}-dev"].spoke_gateway.gw_name
}

resource "aviatrix_segmentation_network_domain_association" "qa_aws_east_1" {
  transit_gateway_name = module.backbone.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  network_domain_name  = aviatrix_segmentation_network_domain.qa.domain_name
  attachment_name      = module.spokes["${var.aws_accounting_account_name}-qa"].spoke_gateway.gw_name
}

resource "aviatrix_segmentation_network_domain_association" "qa_aws_east_2" {
  transit_gateway_name = module.backbone.transit["aws_${replace(lower(var.transit_aws_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  network_domain_name  = aviatrix_segmentation_network_domain.qa.domain_name
  attachment_name      = module.spokes["${var.aws_engineering_account_name}-qa"].spoke_gateway.gw_name
}

resource "aviatrix_segmentation_network_domain_association" "qa_gcp" {
  transit_gateway_name = module.backbone.transit["gcp_${replace(lower(var.transit_gcp_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  network_domain_name  = aviatrix_segmentation_network_domain.qa.domain_name
  attachment_name      = module.spokes["${var.gcp_enterprise_data_account_name}-qa"].spoke_gateway.gw_name
}

resource "aviatrix_segmentation_network_domain_association" "prod_aws_east_1" {
  transit_gateway_name = module.backbone.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  network_domain_name  = aviatrix_segmentation_network_domain.prod.domain_name
  attachment_name      = module.spokes["${var.aws_accounting_account_name}-prod"].spoke_gateway.gw_name
}

resource "aviatrix_segmentation_network_domain_association" "prod_aws_east_2" {
  transit_gateway_name = module.backbone.transit["aws_${replace(lower(var.transit_aws_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  network_domain_name  = aviatrix_segmentation_network_domain.prod.domain_name
  attachment_name      = module.spokes["${var.aws_engineering_account_name}-prod"].spoke_gateway.gw_name
}

resource "aviatrix_segmentation_network_domain_association" "prod_gcp" {
  transit_gateway_name = module.backbone.transit["gcp_${replace(lower(var.transit_gcp_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  network_domain_name  = aviatrix_segmentation_network_domain.prod.domain_name
  attachment_name      = module.spokes["${var.gcp_enterprise_data_account_name}-prod"].spoke_gateway.gw_name
}

resource "aviatrix_segmentation_network_domain_association" "onprem_aws_east_1" {
  transit_gateway_name = module.backbone.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  network_domain_name  = aviatrix_segmentation_network_domain.onprem.domain_name
  attachment_name      = module.avx_landing_zone.spoke_gateway.gw_name
}
