output "palo_alb" {
  description = "The outputs for the palo alto firewall alb"
  value       = aws_lb.palo
}

output "workload_instances" {
  description = "List of deployed workload instance names"
  value = {
    apps   = formatlist("%s.demo.aviatrixtest.com", local.apps)
    data   = formatlist("%s.demo.aviatrixtest.com", local.data)
    shared = formatlist("%s.demo.aviatrixtest.com", local.shared)
  }
}

output "shared_eks" {
  sensitive = true
  value = {
    cluster_id                         = module.shared_eks.eks.cluster_arn
    cluster_name                       = module.shared_eks.eks.cluster_name
    cluster_certificate_authority_data = module.shared_eks.eks.cluster_certificate_authority_data
    cluster_endpoint                   = module.shared_eks.eks.cluster_endpoint
  }
}

output "shared_aks" {
  sensitive = true
  value = {
    cluster_id             = module.shared_aks.aks.id
    host                   = module.shared_aks.aks.kube_config[0].host
    username               = module.shared_aks.aks.kube_config[0].username
    password               = module.shared_aks.aks.kube_config[0].password
    client_certificate     = base64decode(module.shared_aks.aks.kube_config[0].client_certificate)
    client_key             = base64decode(module.shared_aks.aks.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(module.shared_aks.aks.kube_config[0].cluster_ca_certificate)
    spoke                  = module.spoke_azure_k8s
  }
}
