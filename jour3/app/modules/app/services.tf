# Services internes : le frontend les appelle par leur nom (http://service-a:8080).
resource "kubernetes_service_v1" "internal" {
  for_each = toset(["service-a", "service-b"])

  metadata {
    name      = each.key
    namespace = var.namespace
  }

  spec {
    type     = "ClusterIP"
    selector = { app = each.key }

    port {
      port        = 8080
      target_port = 8080
    }
  }
}
