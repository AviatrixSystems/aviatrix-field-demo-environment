locals {
  public_key = fileexists("~/.ssh/id_rsa.pub") ? "${file("~/.ssh/id_rsa.pub")}" : var.public_key

  regional_spokes = flatten([
    for region in local.backbone : [
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

  backbone = {
    ("aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}") = {
      department_spokes = {
        (var.aws_accounting_account_name) = ["dev", "qa", "prod"]
      }
      transit_name                                 = "transit-aws-${var.transit_aws_palo_firenet_region}"
      transit_cloud                                = "aws"
      transit_cidr                                 = "10.1.0.0/23"
      transit_region_name                          = var.transit_aws_palo_firenet_region
      transit_asn                                  = 65101
      transit_instance_size                        = "c5.xlarge"
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
      transit_name          = "transit-azure-${replace(lower(var.transit_azure_region), "/[ ]/", "-")}"
      transit_cloud         = "azure"
      transit_cidr          = "10.2.0.0/23"
      transit_region_name   = var.transit_azure_region
      transit_asn           = 65102
      transit_instance_size = "Standard_B1ms"
    },
    ("oci_${replace(lower(var.transit_oci_region), "/[ -]/", "_")}") = {
      department_spokes = {
        (var.oci_operations_account_name) = ["shared"]
      }
      transit_name          = "transit-oci-${var.transit_oci_region}"
      transit_cloud         = "oci"
      transit_cidr          = "10.3.0.0/23"
      transit_region_name   = var.transit_oci_region
      transit_asn           = 65103
      transit_instance_size = "VM.Standard2.2"
    },
    ("gcp_${replace(lower(var.transit_gcp_region), "/[ -]/", "_")}") = {
      department_spokes = {
        (var.gcp_enterprise_data_account_name) = ["dev", "qa", "prod"]
      }
      transit_name          = "transit-gcp-${var.transit_gcp_region}"
      transit_cloud         = "gcp"
      transit_cidr          = "10.4.0.0/23"
      transit_region_name   = var.transit_gcp_region
      transit_asn           = 65104
      transit_instance_size = "n1-standard-1"
    },
    ("aws_${replace(lower(var.transit_aws_region), "/[ -]/", "_")}") = {
      department_spokes = {
        (var.aws_engineering_account_name) = ["dev", "qa", "prod"]
      }
      transit_name          = "transit-aws-${var.transit_aws_region}"
      transit_cloud         = "aws"
      transit_cidr          = "10.5.0.0/23"
      transit_region_name   = var.transit_aws_region
      transit_asn           = 65105
      transit_instance_size = "c5.xlarge"
      transit_insane_mode   = true
    },
  }

  edge_prefix = "sv-metro-equinix-demo"

  cidrs = {
    onprem      = "10.5.2.0/24"
    avx_landing = "10.7.2.0/24"
  }

  external = [
    "aws.amazon.com",
    "azure.microsoft.com/en-us",
    "cloud.google.com",
    "www.oracle.com/cloud",
    "us.alibabacloud.com",
    "aviatrix.com",
    "ransomware.org",
    "malware.net",
    "botnet.com"
  ]

  apps          = [for d in local.traffic_gen : d.name if length(regexall(".*shared.*", d.name)) == 0 && length(regexall(".*data.*", d.name)) == 0]
  data          = [for d in local.traffic_gen : d.name if length(regexall(".*data.*", d.name)) > 0]
  shared        = [for d in local.traffic_gen : d.name if length(regexall(".*shared.*", d.name)) > 0]
  all_workloads = [for d in local.traffic_gen : d.name]

  traffic_gen = {
    accounting_dev = {
      # TODO: Calculate possibly changing region label
      private_ip = cidrhost(cidrsubnet("${trimsuffix(local.backbone.aws_us_east_1.transit_cidr, "23")}16", 8, 2), 10)
      name       = "accounting-app-dev"
      interval   = "10"
    }
    accounting_qa = {
      private_ip = cidrhost(cidrsubnet("${trimsuffix(local.backbone.aws_us_east_1.transit_cidr, "23")}16", 8, 3), 10)
      name       = "accounting-app-qa"
      interval   = "15"
    }
    accounting_prod = {
      private_ip = cidrhost(cidrsubnet("${trimsuffix(local.backbone.aws_us_east_1.transit_cidr, "23")}16", 8, 4), 10)
      name       = "accounting-app-prod"
      interval   = "5"
    }
    engineering_dev = {
      private_ip = cidrhost(cidrsubnet("${trimsuffix(local.backbone.aws_us_east_2.transit_cidr, "23")}16", 8, 2), 10)
      name       = "engineering-app-dev"
      interval   = "10"
    }
    engineering_qa = {
      private_ip = cidrhost(cidrsubnet("${trimsuffix(local.backbone.aws_us_east_2.transit_cidr, "23")}16", 8, 3), 10)
      name       = "engineering-app-qa"
      interval   = "15"
    }
    engineering_prod = {
      private_ip = cidrhost(cidrsubnet("${trimsuffix(local.backbone.aws_us_east_2.transit_cidr, "23")}16", 8, 4), 10)
      name       = "engineering-app-prod"
      interval   = "5"
    }
    marketing_dev = {
      private_ip = cidrhost(cidrsubnet("${trimsuffix(local.backbone.azure_north_europe.transit_cidr, "23")}16", 8, 2), 40)
      name       = "marketing-app-dev"
      interval   = "10"
    }
    marketing_qa = {
      private_ip = cidrhost(cidrsubnet("${trimsuffix(local.backbone.azure_north_europe.transit_cidr, "23")}16", 8, 2), 70)
      name       = "marketing-app-qa"
      interval   = "15"
    }
    marketing_prod = {
      private_ip = cidrhost(cidrsubnet("${trimsuffix(local.backbone.azure_north_europe.transit_cidr, "23")}16", 8, 2), 100)
      name       = "marketing-app-prod"
      interval   = "5"
    }
    operations_shared = {
      private_ip = cidrhost(cidrsubnet("${trimsuffix(local.backbone.oci_ap_singapore_1.transit_cidr, "23")}16", 8, 2), 20)
      name       = "operations-app-shared"
    }
    enterprise_data_dev = {
      private_ip = cidrhost(cidrsubnet("${trimsuffix(local.backbone.gcp_us_west1.transit_cidr, "23")}16", 8, 2), 10)
      name       = "enterprise-data-dev"
    }
    enterprise_data_qa = {
      private_ip = cidrhost(cidrsubnet("${trimsuffix(local.backbone.gcp_us_west1.transit_cidr, "23")}16", 8, 3), 10)
      name       = "enterprise-data-qa"
    }
    enterprise_data_prod = {
      private_ip = cidrhost(cidrsubnet("${trimsuffix(local.backbone.gcp_us_west1.transit_cidr, "23")}16", 8, 4), 10)
      name       = "enterprise-data-prod"
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

variable "workload_template_path" {
  description = "Path to the workload templates"
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

variable "workload_instance_password" {
  description = "Password for the workload instances"
}

variable "onprem_region" {
  description = "Aws onprem region"
  default     = "sa-east-1"
}

variable "s2c_shared_secret" {
  description = "Shared secret or s2c ipsec tunnels"
}

variable "transit_aws_palo_firenet_region" {
  description = "Aws transit region with palo alto firenet"
  default     = "us-east-1"
}

variable "transit_aws_region" {
  description = "Aws transit region"
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

variable "edge_gcp_region" {
  description = "Edge gcp region"
  default     = "us-south1"
}

variable "edge_prefix" {
  description = "Edge gateway prefix"
  default     = "sv-metro-demo-equinix"
}

variable "public_key" {
  description = "SSH public key to apply to all deployed instances"
}

variable "private_key_full_path" {
  description = "SSH private key to be used to connect to all deployed instances"
}

variable "oci_operations_compartment_ocid" {
  description = "Access account compartment ocid for the oci account for the operations department"
}

variable "common_tags" {
  description = "Optional tags to be applied to all resources"
  default     = {}
}

variable "dashboard_public_cert" {
  description = "Public key certificate for the connectivity dashboard"
  default     = {}
}
variable "dashboard_private_key" {
  description = "Private key certificate for the connectivity dashboard"
  default     = {}
}
