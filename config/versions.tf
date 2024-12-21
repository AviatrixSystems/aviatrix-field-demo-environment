terraform {
  backend "s3" {
    bucket  = "demo.aviatrixtest.com"
    key     = "terraform/controller-config.tfstate"
    region  = "us-west-2"
    profile = "demo_operations"
  }

  required_providers {
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = "~> 3.1.0"
    }
    http-full = {
      source  = "salrashid123/http-full"
      version = "~> 1.3.1"
    }
  }
  required_version = ">= 1.2.0"
}
