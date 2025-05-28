output "workload_instances" {
  description = "List of deployed workload instance names"
  value       = module.demo.workload_instances
}

output "shared_eks" {
  sensitive = true
  value     = module.demo.shared_eks
}

output "shared_aks" {
  sensitive = true
  value     = module.demo.shared_aks
}
