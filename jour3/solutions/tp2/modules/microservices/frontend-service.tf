# Seul point d'entrée public : Azure crée une IP publique, libérée avec le Service.
resource "kubernetes_service_v1" "frontend" {
  metadata {
    name      = "frontend"
    namespace = var.namespace
    annotations = var.dns_label_enabled ? {
      "service.beta.kubernetes.io/azure-dns-label-name" = "tf-${var.prenom}"
    } : {}
  }

  spec {
    type     = "LoadBalancer"
    selector = { app = "frontend" }

    port {
      port        = 80
      target_port = 8080
    }
  }
}
