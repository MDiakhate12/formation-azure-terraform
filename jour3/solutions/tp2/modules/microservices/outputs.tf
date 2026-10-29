output "namespace" {
  value = var.namespace
}

output "dns_url" {
  description = "Adresse par le nom DNS d'Azure, seulement si dns_label_enabled"
  value       = var.dns_label_enabled ? "http://tf-${var.prenom}.${var.location}.cloudapp.azure.com" : null
}

locals {
  lb = kubernetes_service_v1.frontend.status[0]
}

output "url" {
  value = "http://${local.lb.load_balancer[0].ingress[0].ip}"
}
