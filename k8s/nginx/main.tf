resource "kubernetes_deployment" "this" {
  metadata {
    namespace = var.namespace
    name      = var.name
    labels = {
      App = var.name
    }
  }

  spec {
    replicas = var.replicas
    selector {
      match_labels = {
        App = var.name
      }
    }
    template {
      metadata {
        labels = {
          App = var.name
        }
      }
      spec {
        container {
          image = var.image
          name  = var.name

          port {
            container_port = var.container_port
          }

          resources {
            limits = {
              cpu    = var.limits_cpu
              memory = var.limits_memory
            }
            requests = {
              cpu    = var.requests_cpu
              memory = var.requests_memory
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "nginx" {
  metadata {
    namespace = var.namespace
    name      = var.name
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internal"
      "service.beta.kubernetes.io/aws-load-balancer-internal" : "true"
    }
  }
  spec {
    selector = {
      App = kubernetes_deployment.this.spec.0.template.0.metadata[0].labels.App
    }
    port {
      node_port   = var.node_port
      port        = var.port
      target_port = var.container_port
    }

    type = "LoadBalancer"
  }
}

# # resource "kubernetes_deployment_v1" "test_deployment" {
# #   metadata {
# #     name      = "testsvc"
# #     namespace = kubernetes_namespace.test_namespace.metadata.0.name
# #   }

# #   spec {
# #     replicas = 1

# #     selector {
# #       match_labels = {
# #         app = "test"
# #       }
# #     }

# #     template {
# #       metadata {
# #         labels = {
# #           app = "test"
# #         }
# #       }

# #       spec {
# #         container {
# #           name  = "node"
# #           image = "node:lts-alpine"

# #           port {
# #             container_port = 3000
# #             name           = "http"
# #             protocol       = "TCP"
# #           }

# #           volume_mount {
# #             name       = "node-script"
# #             mount_path = "/usr/local/bin/nodeserver.js"
# #             sub_path   = "nodeserver.js"
# #           }

# #           command = ["node", "/usr/local/bin/nodeserver.js"]
# #         }

# #         container {
# #           name  = "curl"
# #           image = "alpine/curl"

# #           command           = ["sleep", "3600"]
# #           image_pull_policy = "IfNotPresent"
# #         }

# #         volume {
# #           name = "node-script"

# #           config_map {
# #             name         = "node-script"
# #             default_mode = "0755"
# #           }
# #         }
# #       }
# #     }
# #   }
# # }

# # resource "kubernetes_deployment_v1" "test_deployment2" {
# #   metadata {
# #     name      = "testsvc2"
# #     namespace = kubernetes_namespace.test_namespace.metadata.0.name
# #   }

# #   spec {
# #     replicas = 1

# #     selector {
# #       match_labels = {
# #         app = "test2"
# #       }
# #     }

# #     template {
# #       metadata {
# #         labels = {
# #           app = "test2"
# #         }
# #       }

# #       spec {
# #         container {
# #           name  = "node"
# #           image = "node:lts-alpine"

# #           port {
# #             container_port = 3000
# #             name           = "http"
# #             protocol       = "TCP"
# #           }

# #           volume_mount {
# #             name       = "node-script"
# #             mount_path = "/usr/local/bin/nodeserver.js"
# #             sub_path   = "nodeserver.js"
# #           }

# #           command = ["node", "/usr/local/bin/nodeserver.js"]
# #         }

# #         container {
# #           name  = "curl"
# #           image = "alpine/curl"

# #           command           = ["sleep", "3600"]
# #           image_pull_policy = "IfNotPresent"
# #         }

# #         volume {
# #           name = "node-script"

# #           config_map {
# #             name         = "node-script"
# #             default_mode = "0755"
# #           }
# #         }
# #       }
# #     }
# #   }
# # }

# # resource "kubernetes_config_map_v1" "node_script" {
# #   metadata {
# #     name      = "node-script"
# #     namespace = kubernetes_namespace.test_namespace.metadata.0.name
# #   }
# #   data = {
# #     "nodeserver.js" = file("nodeserver.js")
# #   }
# # }

# # resource "kubernetes_service_v1" "test_service" {
# #   metadata {
# #     name      = "testsvc"
# #     namespace = kubernetes_namespace.test_namespace.metadata.0.name

# #     annotations = {
# #       #"service.beta.kubernetes.io/aws-load-balancer-nlb-target-type": "ip"
# #       "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internal"
# #       "service.beta.kubernetes.io/aws-load-balancer-internal" : "true"
# #     }
# #   }

# #   spec {
# #     selector = {
# #       app = "test"
# #     }

# #     port {
# #       port        = 8888
# #       target_port = "http"
# #     }

# #     type = "LoadBalancer"
# #   }
# # }

# # resource "kubernetes_service_v1" "test_service2" {
# #   metadata {
# #     name      = "testsvc2"
# #     namespace = kubernetes_namespace.test_namespace.metadata.0.name

# #     annotations = {
# #       #"service.beta.kubernetes.io/aws-load-balancer-nlb-target-type": "ip"
# #       "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internal"
# #       "service.beta.kubernetes.io/aws-load-balancer-internal" : "true"
# #     }
# #   }

# #   spec {
# #     selector = {
# #       app = "test2"
# #     }

# #     port {
# #       port        = 8888
# #       target_port = "http"
# #     }

# #     type = "LoadBalancer"
# #   }
# # }
