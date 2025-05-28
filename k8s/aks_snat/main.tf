# Disable SNAT for all traffic to IPs in our aviatrix network
resource "kubernetes_config_map_v1" "this" {
  metadata {
    name      = "azure-ip-masq-agent-config"
    namespace = "kube-system"
    labels = {
      component                         = "ip-masq-agent"
      "kubernetes.io/cluster-service"   = "true"
      "addonmanager.kubernetes.io/mode" = "EnsureExists"
    }
  }
  data = {
    "ip-masq-agent" = <<-EOT
      nonMasqueradeCIDRs:
        - "0.0.0.0/0"
    EOT
  }
}
