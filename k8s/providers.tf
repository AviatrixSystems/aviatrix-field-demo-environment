provider "aviatrix" {
  username                = local.tfvars.ctrl_username
  password                = local.tfvars.ctrl_password
  controller_ip           = local.tfvars.ctrl_fqdn
  skip_version_validation = true
}

provider "aws" {
  profile = "demo_operations"
  region  = "us-west-2"
}

provider "aws" {
  alias   = "us-east-1"
  profile = "demo_operations"
  region  = "us-east-1"
}

provider "aws" {
  alias   = "sms"
  region  = "us-east-1"
  profile = "pod1"
}

provider "kubernetes" {
  alias                  = "shared_eks"
  host                   = data.terraform_remote_state.k8s.outputs.shared_eks.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.k8s.outputs.shared_eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.shared_eks.token
}

provider "kubernetes" {
  alias                  = "shared_aks"
  host                   = data.terraform_remote_state.k8s.outputs.shared_aks.host
  username               = data.terraform_remote_state.k8s.outputs.shared_aks.username
  password               = data.terraform_remote_state.k8s.outputs.shared_aks.password
  client_certificate     = data.terraform_remote_state.k8s.outputs.shared_aks.client_certificate
  client_key             = data.terraform_remote_state.k8s.outputs.shared_aks.client_key
  cluster_ca_certificate = data.terraform_remote_state.k8s.outputs.shared_aks.cluster_ca_certificate
}
