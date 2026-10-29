output "app_url" {
  value = module.microservices.url
}

# Pour aller plus loin : vide tant que dns_label_enabled vaut false
output "app_dns_url" {
  value = module.microservices.dns_url
}
