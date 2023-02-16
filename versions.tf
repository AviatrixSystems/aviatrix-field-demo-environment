terraform {
  backend "s3" {
    bucket  = "tf.aviatrixlab.com"
    key     = "demo/terraform-airspace.tfstate"
    region  = "us-east-2"
    profile = "pod1"
  }

  required_providers {
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = "~> 3.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.54.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.43.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.52.0"
    }
    oci = {
      source  = "hashicorp/oci"
      version = "~> 4.107.0"
    }
  }
  required_version = ">= 1.2.0"
}
