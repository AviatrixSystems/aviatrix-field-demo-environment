data "aws_caller_identity" "aws_account" {}

data "http" "myip" {
  url = "http://ifconfig.me"
}

resource "aws_cloudformation_stack" "avx_ctrl_cplt" {
  name         = "avxlabs-simple-deployment"
  template_url = "https://s3.us-west-2.amazonaws.com/public.aviatrixlab.com/avx_simple_deployment.yaml"
  capabilities = ["CAPABILITY_IAM"]
  parameters = {
    AdminEmail                  = local.tfvars.account_email
    AdminPassword               = local.tfvars.ctrl_password
    AdminPasswordConfirm        = local.tfvars.ctrl_password
    AllowedHttpsIngressIpParam  = "${chomp(data.http.myip.response_body)}/32"
    ControllerInstanceTypeParam = var.controller_instance_type
    CoPilotInstanceTypeParam    = var.copilot_instance_type
    HTTPProxy                   = "-"
    HTTPSProxy                  = "-"
    CustomerId                  = local.tfvars.ctrl_customer_id
    DataVolSize                 = 100
    SubnetAZ                    = "${var.aws_region}a"
    SubnetCidr                  = var.subnet_cidr
    TargetVersion               = "7.1"
    VpcCidr                     = var.vpc_cidr
  }
  lifecycle {
    ignore_changes = [parameters["AdminPassword"], parameters["AdminPasswordConfirm"]]
  }
}

# module "aviatrix_controller_aws" {
#   source                      = "AviatrixSystems/aws-controller/aviatrix"
#   version                     = "1.0.3"
#   access_account_email        = local.tfvars.account_email
#   access_account_name         = local.tfvars.aws_account_name
#   admin_email                 = local.tfvars.account_email
#   admin_password              = local.tfvars.ctrl_password
#   aws_account_id              = data.aws_caller_identity.aws_account.account_id
#   secondary_account_ids       = [local.tfvars.aws_engineering_account_number, local.tfvars.aws_accounting_account_number]
#   controller_version          = local.tfvars.ctrl_version
#   customer_license_id         = local.tfvars.ctrl_customer_id
#   use_existing_keypair        = true
#   key_pair_name               = aws_key_pair.avx_ctrl_key.key_name
#   termination_protection      = true
#   incoming_ssl_cidrs          = ["${chomp(data.http.myip.response_body)}/32"]
#   instance_type               = var.controller_instance_type
#   type                        = "BYOL"
#   controller_launch_wait_time = "210"
#   vpc_cidr                    = var.vpc_cidr
#   subnet_cidr                 = var.subnet_cidr
#   controller_tags             = local.tfvars.common_tags
# }

# resource "aws_ebs_volume" "copilot" {
#   availability_zone = "${var.aws_region}a"
#   encrypted         = true
#   type              = "gp2"
#   size              = 1000
# }

# module "aviatrix_copilot_aws" {
#   source                = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_aws?ref=7d9d111b1181ac8b21540a7ac767da5422ca2301"
#   use_existing_keypair  = true
#   keypair               = aws_key_pair.avx_ctrl_key.key_name
#   controller_public_ip  = module.aviatrix_controller_aws.public_ip
#   controller_private_ip = module.aviatrix_controller_aws.private_ip
#   instance_type         = var.copilot_instance_type
#   use_existing_vpc      = true
#   vpc_id                = module.aviatrix_controller_aws.vpc_id
#   subnet_id             = module.aviatrix_controller_aws.subnet_id
#   tags                  = local.tfvars.common_tags

#   allowed_cidrs = {}
#   additional_volumes = {
#     "one" = {
#       device_name = "/dev/sda2"
#       volume_id   = aws_ebs_volume.copilot.id
#     }
#   }
# }

# resource "aws_security_group_rule" "copilot_controller" {
#   type              = "ingress"
#   description       = "Allows HTTPS inbound from copilot"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   cidr_blocks       = ["${module.aviatrix_copilot_aws.public_ip}/32"]
#   security_group_id = module.aviatrix_controller_aws.security_group_id
# }

# resource "aws_security_group_rule" "controller_copilot" {
#   type              = "ingress"
#   description       = "Allows HTTPS inbound from copilot"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   cidr_blocks       = ["${module.aviatrix_controller_aws.public_ip}/32"]
#   security_group_id = tolist(module.aviatrix_copilot_aws.ec2-info[0].vpc_security_group_ids)[0]
# }

# resource "aws_security_group_rule" "controller_copilot_syslog" {
#   type              = "ingress"
#   description       = "Allows syslog inbound from the controller"
#   from_port         = 5000
#   to_port           = 5000
#   protocol          = "udp"
#   cidr_blocks       = ["${module.aviatrix_controller_aws.public_ip}/32"]
#   security_group_id = tolist(module.aviatrix_copilot_aws.ec2-info[0].vpc_security_group_ids)[0]
# }

# resource "aws_security_group_rule" "controller_copilot_netflow" {
#   type              = "ingress"
#   description       = "Allows netflow inbound from the controller"
#   from_port         = 31283
#   to_port           = 31283
#   protocol          = "udp"
#   cidr_blocks       = ["${module.aviatrix_controller_aws.public_ip}/32"]
#   security_group_id = tolist(module.aviatrix_copilot_aws.ec2-info[0].vpc_security_group_ids)[0]
# }
