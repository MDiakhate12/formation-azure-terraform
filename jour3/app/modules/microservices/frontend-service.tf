resource "kubernetes_service_v1" "frontend" {
  metadata {
    name      = "frontend"
    namespace = var.namespace
    annotations = var.dns_label_enabled ? {
      "service.beta.kubernetes.io/azure-dns-label-name" = "tf-${var.prenom}"
    } : {}
  }

  spec {
    type     = "LoadBalancer"                 # À COMPLÉTER : LoadBalancer
    selector = { app = "frontend" }       # À COMPLÉTER : le label des pods du frontend, frontend

    port {
      port        = 80              # À COMPLÉTER : 80, le port exposé sur Internet
      target_port = 8080              # À COMPLÉTER : 8080, le port du conteneur
    }
  }
}
