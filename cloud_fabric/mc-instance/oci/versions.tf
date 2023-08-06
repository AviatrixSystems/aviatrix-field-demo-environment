terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.110.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.3"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.3"
    }
  }
  required_version = ">= 1.0.0"
}
