resource "aviatrix_fqdn" "allow_egress" {
  fqdn_tag            = "allow_egress"
  fqdn_enabled        = true
  fqdn_mode           = "white"
  manage_domain_names = false
  gw_filter_tag_list {
    gw_name = module.multicloud_transit.firenet["aws_${replace(lower(var.transit_aws_egress_fqdn_region), "/[ -]/", "_")}"].aviatrix_firewall_instance[0].gw_name
  }
}

resource "aviatrix_fqdn_tag_rule" "tcp" {
  for_each      = local.egress_rules.tcp
  fqdn_tag_name = aviatrix_fqdn.allow_egress.fqdn_tag
  fqdn          = each.key
  protocol      = "tcp"
  port          = each.value
}

resource "aviatrix_fqdn_tag_rule" "udp" {
  for_each      = local.egress_rules.udp
  fqdn_tag_name = aviatrix_fqdn.allow_egress.fqdn_tag
  fqdn          = each.key
  protocol      = "udp"
  port          = each.value
}

resource "aviatrix_transit_firenet_policy" "egress_spokes" {
  for_each                     = { for spoke in local.regional_spokes : "${spoke.avx_account}-${spoke.spoke}" => spoke if "${spoke.avx_account}" == var.aws_engineering_account_name }
  transit_firenet_gateway_name = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_egress_fqdn_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  inspected_resource_name      = "SPOKE:${module.spokes["${each.value.avx_account}-${each.value.spoke}"].spoke_gateway.gw_name}"
  depends_on = [
    module.multicloud_transit
  ]
}
