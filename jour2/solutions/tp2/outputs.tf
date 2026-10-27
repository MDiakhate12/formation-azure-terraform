output "manuel_id" {
  value = azurerm_resource_group.manuel.id
}

output "shared_resource_group" {
  value = {
    id       = data.azurerm_resource_group.shared.id
    location = data.azurerm_resource_group.shared.location
  }
}
