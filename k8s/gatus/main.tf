resource "kubernetes_config_map_v1" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }
  data = {
    "config.yaml" = var.configuration_file_content
  }
}

resource "kubernetes_deployment_v1" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      app = var.name
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = var.name
      }
    }
    template {
      metadata {
        name      = var.name
        namespace = var.namespace
        labels = {
          app = var.name
        }
        annotations = {
          // Used to automatically trigger restart on config change
          config_hash = sha1(jsonencode(kubernetes_config_map_v1.this.data))
        }
      }
      spec {
        container {
          name              = var.name
          image             = var.image
          image_pull_policy = "IfNotPresent"
          port {
            name           = "http"
            container_port = 8080
          }
          resources {
            requests = {
              cpu    = var.cpu_request
              memory = var.memory_request
            }
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
          }
          dynamic "env" {
            for_each = var.environment_variables
            content {
              name  = env.key
              value = env.value
            }
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = "8080"
            }
            initial_delay_seconds = 2
            period_seconds        = 8
            failure_threshold     = 1
            success_threshold     = 1
            timeout_seconds       = 2
          }
          liveness_probe {
            http_get {
              path = "/health"
              port = "8080"
            }
            initial_delay_seconds = 2
            period_seconds        = 8
            failure_threshold     = 3
            success_threshold     = 1
            timeout_seconds       = 2
          }
          volume_mount {
            mount_path = "/config"
            name       = "${var.name}-config"
          }
        }
        volume {
          name = "${var.name}-config"
          config_map {
            name = kubernetes_config_map_v1.this.metadata[0].name
          }
        }
        security_context {
          sysctl { # Needed for ICMP to work without root privileges
            name  = "net.ipv4.ping_group_range"
            value = "0 65536"
          }
        }
        node_selector = var.node_selector
      }
    }
  }
}

resource "kubernetes_service_v1" "this" {
  metadata {
    name        = var.name
    namespace   = var.namespace
    annotations = var.ingress_annotations
  }
  spec {
    port {
      protocol    = "TCP"
      name        = "http"
      port        = var.port
      target_port = 8080
    }
    selector = {
      app = var.name
    }
    type = "LoadBalancer"
  }
}
