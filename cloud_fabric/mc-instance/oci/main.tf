data "cloudinit_config" "this" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = var.user_data_templatefile
  }
}

data "oci_core_images" "ubuntu_22_04" {
  compartment_id = var.oci_compartment_ocid
  display_name   = "Canonical-Ubuntu-22.04-2023.05.19-0"
}

resource "oci_core_network_security_group" "this" {
  compartment_id = var.oci_compartment_ocid
  vcn_id         = var.oci_vcn_ocid
  display_name   = "Instance Security Group"
}

resource "oci_core_network_security_group_security_rule" "this_rfc1918" {
  for_each                  = toset(local.rfc_1918)
  network_security_group_id = oci_core_network_security_group.this.id

  description = "Inbound rfc1918"
  direction   = "INGRESS"
  protocol    = "all"
  source_type = "CIDR_BLOCK"
  source      = each.value
}

resource "oci_core_network_security_group_security_rule" "this_egress" {
  network_security_group_id = oci_core_network_security_group.this.id

  description      = "Outbound"
  direction        = "EGRESS"
  protocol         = "all"
  destination_type = "CIDR_BLOCK"
  destination      = "0.0.0.0/0"
}

resource "oci_core_network_security_group_security_rule" "this_tcp" {
  for_each                  = var.inbound_tcp
  network_security_group_id = oci_core_network_security_group.this.id

  description = "Inbound tcp port ${each.key}"
  direction   = "INGRESS"
  protocol    = 6
  source_type = "CIDR_BLOCK"
  source      = each.value
  tcp_options {
    destination_port_range {
      max = each.key
      min = each.key
    }
  }
}

resource "oci_core_network_security_group_security_rule" "this_udp" {
  for_each                  = var.inbound_udp
  network_security_group_id = oci_core_network_security_group.this.id

  description = "Inbound udp port ${each.key}"
  direction   = "INGRESS"
  protocol    = 17
  source_type = "CIDR_BLOCK"
  source      = each.value
  udp_options {
    destination_port_range {
      max = each.key
      min = each.key
    }
  }
}

module "this" {
  source                      = "oracle-terraform-modules/compute-instance/oci"
  version                     = "2.4.1"
  instance_count              = 1 # how many instances do you want?
  ad_number                   = 1 # AD number to provision instances. If null, instances are provisionned in a rolling manner starting with AD1
  compartment_ocid            = var.oci_compartment_ocid
  instance_display_name       = var.name
  source_ocid                 = var.image == null ? data.oci_core_images.ubuntu_22_04.images.0.id : var.image
  subnet_ocids                = [var.subnet_id]
  public_ip                   = var.public_ip ? "EPHEMERAL" : "NONE"
  private_ips                 = var.private_ip != null ? [var.private_ip] : []
  ssh_public_keys             = fileexists("~/.ssh/id_rsa.pub") ? "${file("~/.ssh/avxlabs.pub")}" : null
  block_storage_sizes_in_gbs  = [50]
  instance_flex_memory_in_gbs = 1
  shape                       = var.instance_size
  instance_state              = "RUNNING"
  boot_volume_backup_policy   = "disabled"
  primary_vnic_nsg_ids        = [oci_core_network_security_group.this.id]
  extended_metadata = {
    user_data = data.cloudinit_config.this.rendered
  }
  freeform_tags = merge(local.common_tags, {
    Name = var.name
  })
}
