resource "kubernetes_deployment_v1" "service_a" {
  metadata {
    name      = "service-a"
    namespace = var.namespace
    labels    = { app = "service-a" }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = { app = "service-a" }
    }

    template {
      metadata {
        labels = { app = "service-a" }
      }

      spec {
        node_selector = var.node_selector

        container {
          name  = "service-a"
          image = "${var.registry}/service-a:${var.tag}"

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
