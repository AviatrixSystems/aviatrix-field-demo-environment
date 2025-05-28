# https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-spoke/aviatrix/latest
module "spoke_aws_k8s" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "8.0.0"

  cloud          = "aws"
  name           = "operations-aws-spoke-k8s"
  cidr           = cidrsubnet("10.1.0.0/16", 8, 5)
  region         = var.transit_aws_palo_firenet_region
  account        = var.aws_operations_account_name
  instance_size  = "t3.medium"
  transit_gw     = module.backbone.transit["aws_us_east_1"].transit_gateway.gw_name
  ha_gw          = false
  attached       = true
  single_ip_snat = true
  subnet_size    = "26"
  subnet_pairs   = "2"
}

module "spoke_azure_k8s" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "8.0.0"

  cloud          = "azure"
  name           = "operations-azure-spoke-k8s"
  cidr           = cidrsubnet("10.2.0.0/16", 8, 5)
  region         = var.transit_azure_region
  account        = var.azure_operations_account_name
  instance_size  = "Standard_B2ms"
  transit_gw     = module.backbone.transit["azure_north_europe"].transit_gateway.gw_name
  ha_gw          = false
  attached       = true
  single_ip_snat = true
  subnet_size    = "26"
  subnet_pairs   = "1"
}

locals {
  cluster_names = {
    shared_aws   = "shared-us-east-1-eks"
    shared_azure = "shared-north-europe-aks"
  }
}
resource "null_resource" "aws_k8s_tagging_shared_private" {
  for_each = toset(module.spoke_aws_k8s.vpc.private_subnets.*.subnet_id)
  provisioner "local-exec" {
    command     = <<-EOT
    aws ec2 create-tags \
    --tags Key="kubernetes.io/role/internal-elb",Value=1 Key="kubernetes.io/cluster/${local.cluster_names.shared_aws}",Value="owned" \
    --resources ${each.value} --profile "demo_operations" --region ${var.transit_aws_palo_firenet_region}
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [module.spoke_aws_k8s]
}

resource "null_resource" "aws_k8s_tagging_shared_public" {
  for_each = toset(module.spoke_aws_k8s.vpc.public_subnets.*.subnet_id)
  provisioner "local-exec" {
    command     = <<-EOT
    aws ec2 create-tags \
    --tags Key="kubernetes.io/role/elb",Value=1 Key="kubernetes.io/cluster/${local.cluster_names.shared_aws}",Value="owned" \
    --resources ${each.value} --profile "demo_operations" --region ${var.transit_aws_palo_firenet_region}
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [module.spoke_aws_k8s]
}

data "aviatrix_account" "aws" {
  account_name = "operations-aws"
}

module "shared_eks" {
  source                   = "./eks"
  cluster_name             = local.cluster_names.shared_aws
  vpc_id                   = module.spoke_aws_k8s.vpc.vpc_id
  private_subnet_ids       = module.spoke_aws_k8s.vpc.private_subnets.*.subnet_id
  aviatrix_aws_account_arn = data.aviatrix_account.aws.aws_role_arn
  cluster_instance_size    = "m5.large"
  providers = {
    aws = aws.palo
  }
}

data "aws_iam_roles" "sso_ro" {
  name_regex = "AWSReservedSSO_EKSAdmin.*"
}

resource "aws_eks_access_entry" "shared_eks_ro" {
  cluster_name  = module.shared_eks.eks.cluster_name
  principal_arn = tolist(data.aws_iam_roles.sso_ro.arns)[0]
  type          = "STANDARD"
  provider      = aws.palo
}

resource "aws_eks_access_policy_association" "shared_eks_ro" {
  cluster_name  = module.shared_eks.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
  principal_arn = tolist(data.aws_iam_roles.sso_ro.arns)[0]

  access_scope {
    type = "cluster"
  }
  provider = aws.palo
}

module "shared_aks" {
  source                = "./aks"
  cluster_name          = local.cluster_names.shared_azure
  location              = module.spoke_azure_k8s.vpc.region
  resource_group        = module.spoke_azure_k8s.vpc.resource_group
  resource_id           = module.spoke_azure_k8s.vpc.azure_vnet_resource_id
  subnet_id             = module.spoke_azure_k8s.vpc.private_subnets[0].subnet_id
  ssh_key               = var.public_key
  cluster_instance_size = "Standard_D2_v2" #"Standard_D2_v4" | "Standard_D2s_v4"
  providers = {
    azurerm = azurerm.operations
  }
}
