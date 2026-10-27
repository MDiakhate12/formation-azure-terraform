output "resource_group_id" {
  value = azurerm_resource_group.main.id
}

output "principal_id" {
  value = azurerm_user_assigned_identity.app.principal_id
}

output "my_object_id" {
  description = "Votre propre identité (pour aller plus loin)"
  value       = data.azurerm_client_config.current.object_id
}
