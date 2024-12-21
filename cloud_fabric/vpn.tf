resource "aviatrix_gateway" "vpn" {
  cloud_type            = 1
  account_name          = var.aws_engineering_account_name
  gw_name               = "engineering-aws-spoke-dev-vpn"
  vpc_id                = module.spokes["${var.aws_engineering_account_name}-dev"].vpc.vpc_id
  vpc_reg               = module.spokes["${var.aws_engineering_account_name}-dev"].vpc.region
  gw_size               = "t3.micro"
  subnet                = module.spokes["${var.aws_engineering_account_name}-dev"].vpc.public_subnets[0].cidr
  vpn_access            = true
  vpn_cidr              = "192.168.43.0/24"
  max_vpn_conn          = "100"
  vpn_protocol          = "UDP"
  saml_enabled          = true
  split_tunnel          = true
  additional_cidrs      = "10.0.0.0/13,10.99.2.0/24,10.40.251.0/24,10.50.251.0/24"
  enable_elb            = false
  enable_encrypt_volume = true
}

resource "aviatrix_vpn_user" "shared" {
  vpc_id        = module.spokes["${var.aws_engineering_account_name}-dev"].vpc.vpc_id
  gw_name       = aviatrix_gateway.vpn.gw_name
  user_name     = "aviatrix"
  user_email    = "demo@aviatrix.com"
  saml_endpoint = "aviatrix_vpn_sso"
}

