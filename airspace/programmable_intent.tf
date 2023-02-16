# Distributed firewall
resource "aviatrix_distributed_firewalling_policy_list" "demo" {
  policies {
    name     = "Allow-Dev"
    action   = "PERMIT"
    priority = 10
    protocol = "Any"
    logging  = true
    watch    = false
    src_smart_groups = [
      aviatrix_smart_group.dev.uuid
    ]
    dst_smart_groups = [
      aviatrix_smart_group.dev.uuid
    ]
  }

  policies {
    name     = "Allow-QA"
    action   = "PERMIT"
    priority = 20
    protocol = "Any"
    logging  = true
    watch    = false
    src_smart_groups = [
      aviatrix_smart_group.qa.uuid
    ]
    dst_smart_groups = [
      aviatrix_smart_group.qa.uuid
    ]
  }
  policies {
    name     = "Allow-Prod"
    action   = "PERMIT"
    priority = 30
    protocol = "Any"
    logging  = true
    watch    = false
    src_smart_groups = [
      aviatrix_smart_group.prod.uuid
    ]
    dst_smart_groups = [
      aviatrix_smart_group.prod.uuid
    ]
  }
  policies {
    name     = "Allow-Edge"
    action   = "PERMIT"
    priority = 40
    protocol = "Any"
    logging  = true
    watch    = false
    src_smart_groups = [
      aviatrix_smart_group.edge.uuid
    ]
    dst_smart_groups = [
      aviatrix_smart_group.dev.uuid,
      aviatrix_smart_group.qa.uuid,
      aviatrix_smart_group.prod.uuid
    ]
  }
  policies {
    name     = "Application-Deny-All"
    action   = "DENY"
    priority = 1000
    protocol = "Any"
    logging  = true
    watch    = false
    src_smart_groups = [
      aviatrix_smart_group.dev.uuid,
      aviatrix_smart_group.qa.uuid,
      aviatrix_smart_group.prod.uuid
    ]
    dst_smart_groups = [
      aviatrix_smart_group.dev.uuid,
      aviatrix_smart_group.qa.uuid,
      aviatrix_smart_group.prod.uuid
    ]
  }
  policies {
    name     = "DefaultAllowAll"
    action   = "PERMIT"
    priority = 2147483647
    protocol = "Any"
    logging  = true
    watch    = false
    src_smart_groups = [
      "def000ad-0000-0000-0000-000000000000"
    ]
    dst_smart_groups = [
      "def000ad-0000-0000-0000-000000000000"
    ]
  }
}

# Network segmentation
resource "aviatrix_segmentation_network_domain" "demo" {
  for_each    = toset(local.network_domains)
  domain_name = each.value
}

resource "aviatrix_segmentation_network_domain_association" "demo" {
  for_each            = { for spoke in local.regional_spokes : "${spoke.avx_account}-${spoke.spoke}" => spoke }
  network_domain_name = each.value.spoke == "dev" ? aviatrix_segmentation_network_domain.demo["Dev"].domain_name : each.value.spoke == "qa" ? aviatrix_segmentation_network_domain.demo["QA"].domain_name : each.value.spoke == "prod" ? aviatrix_segmentation_network_domain.demo["Prod"].domain_name : aviatrix_segmentation_network_domain.demo["Azure"].domain_name
  attachment_name     = module.spokes["${each.value.avx_account}-${each.value.spoke}"].spoke_gateway.gw_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "azure_dev" {
  for_each      = { for k, v in toset(setsubtract(local.network_domains, ["Edge", "Azure"])) : k => v } #if v.value != "Edge" || k != "Azure" }
  domain_name_1 = aviatrix_segmentation_network_domain.demo["Azure"].domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.demo["${each.value}"].domain_name
}
