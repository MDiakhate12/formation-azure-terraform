output "resource_group_id" {
  value = azurerm_resource_group.main.id
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "subnet_ids" {
  value = {
    app  = azurerm_subnet.app.id
    data = azurerm_subnet.data.id
  }
}
