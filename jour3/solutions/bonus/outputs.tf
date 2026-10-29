output "get_credentials" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name} --overwrite-existing"
}

output "kube_context" {
  description = "Nom du contexte kubectl, utilisé par le provider kubernetes de jour3/app"
  value       = azurerm_kubernetes_cluster.main.name
}

output "kubernetes_version" {
  value = azurerm_kubernetes_cluster.main.current_kubernetes_version
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.main.node_resource_group
}
