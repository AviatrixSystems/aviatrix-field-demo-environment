output "palo_public_ip" {
  description = "The public ip for the palo alto firewall console"
  value       = module.multicloud_transit.firenet["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].aviatrix_firewall_instance[0].public_ip
}
