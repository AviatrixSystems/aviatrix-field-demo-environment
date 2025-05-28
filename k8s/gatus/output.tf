output "kubernetes_service_name" {
  value = kubernetes_service_v1.this.metadata[0].name
}

output "kubernetes_service_port" {
  value = kubernetes_service_v1.this.spec[0].port[0].port
}

output "kubernetes_eks_service_lb" {
  value = kubernetes_service_v1.this.status.0.load_balancer.0.ingress.0.hostname
}

output "kubernetes_aks_service_lb" {
  value = kubernetes_service_v1.this.status.0.load_balancer.0.ingress.0.ip
}
