resource "aviatrix_vpc" "builder_spoke" {
  for_each     = toset(["aws", "azure", "gcp", "oci"])
  cloud_type   = each.value == "aws" ? 1 : each.value == "azure" ? 8 : each.value == "gcp" ? 4 : 16
  region       = each.value == "aws" ? "us-east-1" : each.value == "azure" ? "East US" : each.value == "gcp" ? null : "us-ashburn-1"
  account_name = each.value == "aws" ? var.aws_operations_account_name : each.value == "azure" ? var.azure_operations_account_name : each.value == "gcp" ? var.gcp_operations_account_name : var.oci_operations_account_name
  name         = each.value == "azure" ? "example-${each.value}-spoke-vnet" : each.value == "oci" ? "example-${each.value}-spoke-vcn" : "example-${each.value}-spoke-vpc"
  cidr         = each.value == "aws" ? "10.101.1.0/24" : each.value == "azure" ? "10.108.1.0/24" : each.value == "gcp" ? null : "10.116.1.0/24"
  dynamic "subnets" {
    for_each = each.value == "gcp" ? ["subnet"] : []

    content {
      name   = "example-${each.value}-spoke-vpc"
      cidr   = "10.104.1.0/24"
      region = "us-east1"
    }
  }
}

resource "aviatrix_vpc" "builder_transit" {
  for_each     = toset(["aws", "azure", "gcp", "oci"])
  cloud_type   = each.value == "aws" ? 1 : each.value == "azure" ? 8 : each.value == "gcp" ? 4 : 16
  region       = each.value == "aws" ? "us-east-1" : each.value == "azure" ? "East US" : each.value == "gcp" ? null : "us-ashburn-1"
  account_name = each.value == "aws" ? var.aws_operations_account_name : each.value == "azure" ? var.azure_operations_account_name : each.value == "gcp" ? var.gcp_operations_account_name : var.oci_operations_account_name
  name         = each.value == "azure" ? "example-${each.value}-transit-vnet" : each.value == "oci" ? "example-${each.value}-transit-vcn" : "example-${each.value}-transit-vpc"
  cidr         = each.value == "aws" ? "10.102.0.0/23" : each.value == "azure" ? "10.109.0.0/23" : each.value == "gcp" ? null : "10.117.0.0/23"
  dynamic "subnets" {
    for_each = each.value == "gcp" ? ["subnet"] : []

    content {
      name   = "example-${each.value}-transit-vpc"
      cidr   = "10.105.0.0/23"
      region = "us-east1"
    }
  }
  aviatrix_firenet_vpc = each.value == "aws" || each.value == "azure" ? true : false
}
