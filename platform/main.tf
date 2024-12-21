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
    ignore_changes = [parameters["AdminPassword"], parameters["AdminPasswordConfirm"], parameters["AllowedHttpsIngressIpParam"]]
  }
}
