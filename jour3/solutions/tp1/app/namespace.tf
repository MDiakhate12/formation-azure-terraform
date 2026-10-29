resource "kubernetes_namespace_v1" "app" {
  metadata {
    name   = "app"
    labels = { owner = var.prenom }
  }
}
