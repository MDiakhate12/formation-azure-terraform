output "namespace" {
  value = var.namespace
}

output "dns_url" {
  description = "Adresse par le nom DNS d'Azure, seulement si dns_label_enabled"
  value       = var.dns_label_enabled ? "http://tf-${var.prenom}.${var.location}.cloudapp.azure.com" : null
}

# TP2 : ajoutez ici l'output url (adresse du Service LoadBalancer du frontend).
