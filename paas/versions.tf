terraform {
  backend "s3" {
    bucket  = "demo.aviatrixtest.com"
    key     = "terraform/paas.tfstate"
    region  = "us-west-2"
    profile = "demo_operations"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.76.0"
    }
    http-full = {
      source  = "salrashid123/http-full"
      version = "~> 1.3.1"
    }
  }
  required_version = ">= 1.5.0"
}
