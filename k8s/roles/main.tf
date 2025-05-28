resource "kubernetes_cluster_role" "this" {
  metadata {
    name = "view-nodes"
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["nodes"]
  }
}

resource "kubernetes_cluster_role_binding" "this" {
  metadata {
    name = "view-nodes"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.this.metadata.0.name
  }

  subject {
    kind      = "Group"
    name      = "view-nodes"
    api_group = "rbac.authorization.k8s.io"
  }
}

