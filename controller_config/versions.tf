terraform {
  backend "s3" {
    bucket  = "tf.aviatrixlab.com"
    key     = "demo/terraform-controller-config.tfstate"
    region  = "us-east-2"
    profile = "pod1"
  }

  required_providers {
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = "~> 3.0.0"
    }
    http-full = {
      source  = "salrashid123/http-full"
      version = "~> 1.3.1"
    }
  }
  required_version = ">= 1.2.0"
}
