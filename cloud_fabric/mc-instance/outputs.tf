output "public_ip" {
  value = var.public_ip ? var.cloud == "aws" ? module.aws["instance"].public_ip : var.cloud == "azure" ? module.azure["instance"].public_ip : var.cloud == "gcp" ? module.gcp["instance"].public_ip : null : null
}

output "private_ip" {
  value = var.cloud == "aws" ? module.aws["instance"].private_ip : var.cloud == "azure" ? module.azure["instance"].private_ip : var.cloud == "gcp" ? module.gcp["instance"].private_ip : null
}
