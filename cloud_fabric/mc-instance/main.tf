module "aws" {
  for_each               = var.cloud == "aws" ? { instance = true } : {}
  source                 = "./aws"
  common_tags            = var.common_tags
  iam_instance_profile   = var.iam_instance_profile
  image                  = var.image
  name                   = var.name
  password               = var.password
  private_ip             = var.private_ip
  public_ip              = var.public_ip
  public_key             = var.public_key
  subnet_id              = var.subnet_id
  user_data_templatefile = var.user_data_templatefile
  vpc_id                 = var.vpc_id
  instance_size          = var.instance_size == null ? "t3.nano" : var.instance_size
  inbound_tcp            = var.inbound_tcp
  inbound_udp            = var.inbound_udp
}

module "azure" {
  for_each               = var.cloud == "azure" ? { instance = true } : {}
  source                 = "./azure"
  common_tags            = var.common_tags
  image                  = var.image
  location               = var.location
  name                   = var.name
  password               = var.password
  private_ip             = var.private_ip
  public_ip              = var.public_ip
  resource_group         = var.resource_group
  subnet_id              = var.subnet_id
  user_data_templatefile = var.user_data_templatefile
  instance_size          = var.instance_size == null ? "Standard_B1ls" : var.instance_size
  inbound_tcp            = var.inbound_tcp
  inbound_udp            = var.inbound_udp
}

module "gcp" {
  for_each               = var.cloud == "gcp" ? { instance = true } : {}
  source                 = "./gcp"
  common_tags            = var.common_tags
  image                  = var.image
  name                   = var.name
  private_ip             = var.private_ip
  public_ip              = var.public_ip
  region                 = var.region
  subnet_id              = var.subnet_id
  user_data_templatefile = var.user_data_templatefile
  vpc_id                 = var.vpc_id
  instance_size          = var.instance_size == null ? "n1-standard-1" : var.instance_size #"f1-micro"
  inbound_tcp            = var.inbound_tcp
  inbound_udp            = var.inbound_udp
}

module "oci" {
  for_each               = var.cloud == "oci" ? { instance = true } : {}
  source                 = "./oci"
  common_tags            = var.common_tags
  image                  = var.image
  name                   = var.name
  oci_compartment_ocid   = var.oci_compartment_ocid
  oci_vcn_ocid           = var.oci_vcn_ocid
  private_ip             = var.private_ip
  public_ip              = var.public_ip
  subnet_id              = var.subnet_id
  user_data_templatefile = var.user_data_templatefile
  instance_size          = var.instance_size == null ? "VM.Standard.E3.Flex" : var.instance_size
  inbound_tcp            = var.inbound_tcp
  inbound_udp            = var.inbound_udp
}
