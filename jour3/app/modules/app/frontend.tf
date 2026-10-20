resource "kubernetes_deployment_v1" "frontend" {
  metadata {
    name      = "frontend"
    namespace = var.namespace
    labels    = { app = "frontend" }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = { app = "frontend" }
    }

    template {
      metadata {
        labels = { app = "frontend" }
      }

      spec {
        node_selector = var.node_selector

        container {
          name  = "frontend"
          image = "${var.registry}/frontend:${var.tag}"

          port {
            container_port = 8080
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }
          }

          resources {
            requests = { cpu = "50m", memory = "64Mi" }
            limits   = { memory = "128Mi" }
          }
        }
      }
    }
  }
}
