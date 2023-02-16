locals {
  network_domains = ["Dev", "QA", "Prod", "Azure", "Edge"]

  regional_spokes = flatten([
    for region in local.transit_firenet : [
      for avx_account, spokes in region.department_spokes : [
        for spoke in spokes : {
          region       = region.transit_region_name
          cloud        = region.transit_cloud
          avx_account  = avx_account
          spoke        = spoke
          transit_cidr = region.transit_cidr
        }
      ]
    ]
  ])

  transit_firenet = {
    ("aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}") = {
      department_spokes = {
        (var.aws_accounting_account_name) = ["dev", "qa", "prod"]
      }
      transit_account                              = var.aws_operations_account_name
      transit_name                                 = "transit-aws-${var.transit_aws_palo_firenet_region}"
      transit_cloud                                = "aws"
      transit_cidr                                 = "10.1.0.0/23"
      transit_region_name                          = var.transit_aws_palo_firenet_region
      transit_asn                                  = 65101
      transit_instance_size                        = "c5.xlarge"
      transit_ha_gw                                = false
      firenet                                      = true
      firenet_firewall_image                       = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
      firenet_bootstrap_bucket_name_1              = aws_s3_bucket.palo.id
      firenet_iam_role_1                           = aws_iam_role.palo.name
      firenet_inspection_enabled                   = true
      firenet_keep_alive_via_lan_interface_enabled = true
    },
    ("azure_${replace(lower(var.transit_azure_region), "/[ -]/", "_")}") = {
      department_spokes = {
        (var.azure_marketing_account_name) = ["all"]
      }
      transit_account       = var.azure_operations_account_name
      transit_name          = "transit-azure-${replace(lower(var.transit_azure_region), "/[ ]/", "-")}"
      transit_cloud         = "azure"
      transit_cidr          = "10.2.0.0/23"
      transit_region_name   = var.transit_azure_region
      transit_asn           = 65102
      transit_instance_size = "Standard_B1ms"
      transit_ha_gw         = false
    },
    ("oci_${replace(lower(var.transit_oci_region), "/[ -]/", "_")}") = {
      department_spokes = {
        (var.oci_operations_account_name) = ["dev", "qa", "prod"]
      }
      transit_account       = var.oci_operations_account_name
      transit_name          = "transit-oci-${var.transit_oci_region}"
      transit_cloud         = "oci"
      transit_cidr          = "10.3.0.0/23"
      transit_region_name   = var.transit_oci_region
      transit_asn           = 65103
      transit_instance_size = "VM.Standard2.2"
      transit_ha_gw         = false
    },
    ("gcp_${replace(lower(var.transit_gcp_region), "/[ -]/", "_")}") = {
      department_spokes = {
        (var.gcp_enterprise_data_account_name) = ["dev", "qa", "prod"]
      }
      transit_account       = var.gcp_operations_account_name
      transit_name          = "transit-gcp-${var.transit_gcp_region}"
      transit_cloud         = "gcp"
      transit_cidr          = "10.4.0.0/23"
      transit_region_name   = var.transit_gcp_region
      transit_asn           = 65104
      transit_instance_size = "n1-standard-1"
      transit_ha_gw         = false
    },
    ("aws_${replace(lower(var.transit_aws_egress_fqdn_region), "/[ -]/", "_")}") = {
      department_spokes = {
        (var.aws_engineering_account_name) = ["dev", "qa", "prod"]
      }
      transit_account        = var.aws_operations_account_name
      transit_name           = "transit-aws-${var.transit_aws_egress_fqdn_region}"
      transit_cloud          = "aws"
      transit_cidr           = "10.5.0.0/23"
      transit_region_name    = var.transit_aws_egress_fqdn_region
      transit_asn            = 65105
      transit_instance_size  = "c5.xlarge"
      transit_ha_gw          = false
      firenet                = true
      firenet_firewall_image = "Aviatrix FQDN Egress Filtering"
      firenet_single_ip_snat = true
    },
  }

  egress_rules = {
    tcp = {
      "*.amazonaws.com"    = "443"
      "*.amazonaws.com"    = "80"
      "aviatrix.com"       = "443"
      "*.aviatrix.com"     = "443"
      "*.amazon.com"       = "443"
      "*.amazon.com"       = "80"
      "stackoverflow.com"  = "443"
      "go.dev"             = "443"
      "*.terraform.io"     = "443"
      "*.microsoft.com"    = "443"
      "*.google.com"       = "443"
      "*.oracle.com"       = "443"
      "*.alibabacloud.com" = "443"
      "*.docker.com"       = "443"
      "*.snapcraft.io"     = "443"
      "*.ubuntu.com"       = "443"
      "*.ubuntu.com"       = "80"
    }
    udp = {
      "dns.google.com" = "53"
    }
  }
}

variable "aws_operations_account_name" {
  description = "Aws access account name for the operations department"
}

variable "aws_engineering_account_name" {
  description = "Aws access account name for the engineering department"
}

variable "aws_accounting_account_name" {
  description = "Aws access account name for the accounting department"
}

variable "azure_marketing_account_name" {
  description = "Azure access account name for the marketing department"
}

variable "azure_operations_account_name" {
  description = "Azure access account name for the operations department"
}

variable "gcp_enterprise_data_account_name" {
  description = "Gcp access account name for the enterprise data department"
}

variable "gcp_operations_account_name" {
  description = "Gcp access account name for the operations department"
}

variable "oci_operations_account_name" {
  description = "Oci access account name for the operations department"
}

variable "palo_bootstrap_path" {
  description = "Path to the palo bootstrap files"
}

variable "palo_bucket_name" {
  description = "S3 bucket for the palo bootstrap files. Must be globally unique"
}

variable "palo_admin_username" {
  description = "Palo alto console admin username"
}

variable "palo_admin_password" {
  description = "Palo alto console admin password"
}

variable "transit_aws_palo_firenet_region" {
  description = "Aws transit region with palo alto firenet"
  default     = "us-east-1"
}

variable "transit_aws_egress_fqdn_region" {
  description = "Aws transit region with avx egress fqdn"
  default     = "us-east-2"
}

variable "transit_azure_region" {
  description = "Azure transit region"
  default     = "Germany West Central"
}

variable "transit_gcp_region" {
  description = "Gcp transit region"
  default     = "us-west1"
}

variable "transit_oci_region" {
  description = "Oci transit region"
  default     = "ap-singapore-1"
}
