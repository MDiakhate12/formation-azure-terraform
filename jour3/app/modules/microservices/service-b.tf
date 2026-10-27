# Une seule instance : le disque Azure (ReadWriteOnce) ne se monte que sur un nœud à la fois.
resource "kubernetes_deployment_v1" "service_b" {
  metadata {
    name      = "service-b"
    namespace = var.namespace
    labels    = { app = "service-b" }
  }

  spec {
    replicas = 1

    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = { app = "service-b" }
    }

    template {
      metadata {
        labels = { app = "service-b" }
      }

      spec {
        node_selector = var.node_selector

        # Les conteneurs tournent avec l'utilisateur 1000 : il doit pouvoir écrire sur le volume.
        security_context {
          fs_group = 1000
        }

        container {
          name  = "service-b"
          image = "${var.registry}/service-b:${var.tag}"

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

          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.data.metadata[0].name
          }
        }
      }
    }
  }
}

# Le disque est créé au premier pod qui l'utilise : sans wait_until_bound = false, l'apply attendrait en vain.
resource "kubernetes_persistent_volume_claim_v1" "data" {
  wait_until_bound = false

  metadata {
    name      = "counter-data"
    namespace = var.namespace
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "managed-csi"

    resources {
      requests = { storage = "1Gi" }
    }
  }
}
