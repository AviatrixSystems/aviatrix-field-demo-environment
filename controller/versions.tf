terraform {
  backend "s3" {
    bucket  = "tf.aviatrixlab.com"
    key     = "demo/terraform.tfstate"
    region  = "us-east-2"
    profile = "pod1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    http-full = {
      source  = "salrashid123/http-full"
      version = "~> 1.3.1"
    }
  }
  required_version = ">= 1.2.0"
}
