output "get_credentials" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
}

output "kubernetes_version" {
  value = azurerm_kubernetes_cluster.main.kubernetes_version
}

output "registry_login_server" {
  value = data.azurerm_container_registry.shared.login_server
}
