data "terraform_remote_state" "k8s" {
  backend = "s3"
  config = {
    bucket  = "demo.aviatrixtest.com"
    key     = "terraform/cloud-fabric.tfstate"
    region  = "us-west-2"
    profile = "demo_operations"
  }
}

# Get an auth token for the eks cluster so that we can configure the kubernetes provider to deploy our test services
data "aws_eks_cluster_auth" "shared_eks" {
  name = data.terraform_remote_state.k8s.outputs.shared_eks.cluster_name
}

module "roles_shared_eks" {
  source = "./roles"
  providers = {
    kubernetes = kubernetes.shared_eks
  }
}

resource "aviatrix_kubernetes_cluster" "shared_eks" {
  cluster_id          = data.terraform_remote_state.k8s.outputs.shared_eks.cluster_id
  use_csp_credentials = true
  depends_on          = [module.roles_shared_eks]
}

resource "aviatrix_kubernetes_cluster" "shared_aks" {
  cluster_id          = lower(data.terraform_remote_state.k8s.outputs.shared_aks.cluster_id)
  use_csp_credentials = true
}

module "shared_aks_snat" {
  source = "./aks_snat"
  providers = {
    kubernetes = kubernetes.shared_aks
  }
}

locals {
  namespaces = [
    "frontend",
    "backend",
    "shared-services"
  ]
  eks_annotations = {
    "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internal"
    "service.beta.kubernetes.io/aws-load-balancer-internal" : "true"
  }
}

resource "kubernetes_namespace" "shared_aks" {
  for_each = toset(local.namespaces)
  metadata {
    name = each.value
  }
  provider = kubernetes.shared_aks
}

resource "kubernetes_namespace" "shared_eks" {
  for_each = toset(local.namespaces)
  metadata {
    name = each.value
  }
  provider = kubernetes.shared_eks
}


locals {
  services = {
    frontend = [
      "accounting-frontend-web-dev",
      "accounting-frontend-web-prod",
      "marketing-frontend-web-dev",
      "marketing-frontend-web-prod",
    ],
    backend = [
      "accounting-backend-api-dev",
      "accounting-backend-api-prod",
      "marketing-backend-api-dev",
      "marketing-backend-api-prod",
    ]
    databases = [
      "enterprise-data-dev",
      "enterprise-data-qa",
      "enterprise-data-prod",
    ]
  }
  egress = [
    "aviatrix.com",
    "malware.net",
    "kubernetes.io",
    "www.cncf.io",
  ]
}

module "accounting_frontend_web_dev" {
  source    = "./gatus"
  name      = "accounting-frontend-web-dev"
  namespace = kubernetes_namespace.shared_eks["frontend"].id
  configuration_file_content = templatefile("${path.module}/templates/gatus.tpl",
    {
      name      = "accounting-frontend-web-dev"
      pod       = terraform.workspace
      egress    = local.egress
      services  = local.services.backend
      databases = []
  })
  port                = 443
  ingress_annotations = local.eks_annotations
  providers = {
    kubernetes = kubernetes.shared_eks
  }
}

module "accounting_frontend_web_prod" {
  source    = "./gatus"
  name      = "accounting-frontend-web-prod"
  namespace = kubernetes_namespace.shared_eks["frontend"].id
  configuration_file_content = templatefile("${path.module}/templates/gatus.tpl",
    {
      name      = "accounting-frontend-web-prod"
      pod       = terraform.workspace
      egress    = local.egress
      services  = local.services.backend
      databases = []
  })
  port                = 443
  ingress_annotations = local.eks_annotations
  providers = {
    kubernetes = kubernetes.shared_eks
  }
}

module "marketing_frontend_web_dev" {
  source    = "./gatus"
  name      = "marketing-frontend-web-dev"
  namespace = kubernetes_namespace.shared_eks["frontend"].id
  configuration_file_content = templatefile("${path.module}/templates/gatus.tpl",
    {
      name      = "marketing-frontend-web-dev"
      pod       = terraform.workspace
      egress    = local.egress
      services  = local.services.backend
      databases = []
  })
  port                = 443
  ingress_annotations = local.eks_annotations
  providers = {
    kubernetes = kubernetes.shared_eks
  }
}

module "marketing_frontend_web_prod" {
  source    = "./gatus"
  name      = "marketing-frontend-web-prod"
  namespace = kubernetes_namespace.shared_eks["frontend"].id
  configuration_file_content = templatefile("${path.module}/templates/gatus.tpl",
    {
      name      = "marketing-frontend-web-prod"
      pod       = terraform.workspace
      egress    = local.egress
      services  = local.services.backend
      databases = []
  })
  port                = 443
  ingress_annotations = local.eks_annotations
  providers = {
    kubernetes = kubernetes.shared_eks
  }
}

module "accounting_backend_api_dev" {
  source    = "./gatus"
  name      = "accounting-backend-api-dev"
  namespace = kubernetes_namespace.shared_aks["backend"].id
  configuration_file_content = templatefile("${path.module}/templates/gatus.tpl",
    {
      name      = "accounting-backend-api-dev"
      pod       = terraform.workspace
      egress    = local.egress
      services  = []
      databases = local.services.databases
  })
  port = 443
  ingress_annotations = {
    "service.beta.kubernetes.io/azure-load-balancer-internal" = "true"
    "service.beta.kubernetes.io/azure-load-balancer-internal-subnet" : data.terraform_remote_state.k8s.outputs.shared_aks.spoke.vpc.private_subnets[0].name
  }
  providers = {
    kubernetes = kubernetes.shared_aks
  }
}

module "accounting_backend_api_prod" {
  source    = "./gatus"
  name      = "accounting-backend-api-prod"
  namespace = kubernetes_namespace.shared_aks["backend"].id
  configuration_file_content = templatefile("${path.module}/templates/gatus.tpl",
    {
      name      = "accounting-backend-api-prod"
      pod       = terraform.workspace
      egress    = local.egress
      services  = []
      databases = local.services.databases
  })
  port = 443
  ingress_annotations = {
    "service.beta.kubernetes.io/azure-load-balancer-internal" = "true"
    "service.beta.kubernetes.io/azure-load-balancer-internal-subnet" : data.terraform_remote_state.k8s.outputs.shared_aks.spoke.vpc.private_subnets[0].name
  }
  providers = {
    kubernetes = kubernetes.shared_aks
  }
}

module "marketing_backend_api_dev" {
  source    = "./gatus"
  name      = "marketing-backend-api-dev"
  namespace = kubernetes_namespace.shared_aks["backend"].id
  configuration_file_content = templatefile("${path.module}/templates/gatus.tpl",
    {
      name      = "marketing-backend-api-dev"
      pod       = terraform.workspace
      egress    = local.egress
      services  = []
      databases = local.services.databases
  })
  port = 443
  ingress_annotations = {
    "service.beta.kubernetes.io/azure-load-balancer-internal" = "true"
    "service.beta.kubernetes.io/azure-load-balancer-internal-subnet" : data.terraform_remote_state.k8s.outputs.shared_aks.spoke.vpc.private_subnets[0].name
  }
  providers = {
    kubernetes = kubernetes.shared_aks
  }
}

module "marketing_backend_api_prod" {
  source    = "./gatus"
  name      = "marketing-backend-api-prod"
  namespace = kubernetes_namespace.shared_aks["backend"].id
  configuration_file_content = templatefile("${path.module}/templates/gatus.tpl",
    {
      name      = "marketing-backend-api-prod"
      pod       = terraform.workspace
      egress    = local.egress
      services  = []
      databases = local.services.databases
  })
  port = 443
  ingress_annotations = {
    "service.beta.kubernetes.io/azure-load-balancer-internal" = "true"
    "service.beta.kubernetes.io/azure-load-balancer-internal-subnet" : data.terraform_remote_state.k8s.outputs.shared_aks.spoke.vpc.private_subnets[0].name
  }
  providers = {
    kubernetes = kubernetes.shared_aks
  }
}

resource "aws_route53_record" "accounting_frontend_web_dev" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "accounting-frontend-web-dev.${data.aws_route53_zone.demo.name}"
  type    = "CNAME"
  ttl     = "1"
  records = [module.accounting_frontend_web_dev.kubernetes_eks_service_lb]
}

resource "aws_route53_record" "accounting_frontend_web_prod" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "accounting-frontend-web-prod.${data.aws_route53_zone.demo.name}"
  type    = "CNAME"
  ttl     = "1"
  records = [module.accounting_frontend_web_prod.kubernetes_eks_service_lb]
}

resource "aws_route53_record" "marketing_frontend_web_dev" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "marketing-frontend-web-dev.${data.aws_route53_zone.demo.name}"
  type    = "CNAME"
  ttl     = "1"
  records = [module.marketing_frontend_web_dev.kubernetes_eks_service_lb]
}

resource "aws_route53_record" "marketing_frontend_web_prod" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "marketing-frontend-web-prod.${data.aws_route53_zone.demo.name}"
  type    = "CNAME"
  ttl     = "1"
  records = [module.marketing_frontend_web_prod.kubernetes_eks_service_lb]
}

resource "aws_route53_record" "accounting_backend_api_dev" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "accounting-backend-api-dev.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [module.accounting_backend_api_dev.kubernetes_aks_service_lb]
}

resource "aws_route53_record" "accounting_backend_api_prod" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "accounting-backend-api-prod.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [module.accounting_backend_api_prod.kubernetes_aks_service_lb]
}

resource "aws_route53_record" "marketing_backend_api_dev" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "marketing-backend-api-dev.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [module.marketing_backend_api_dev.kubernetes_aks_service_lb]
}

resource "aws_route53_record" "marketing_backend_api_prod" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "marketing-backend-api-prod.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [module.marketing_backend_api_prod.kubernetes_aks_service_lb]
}

