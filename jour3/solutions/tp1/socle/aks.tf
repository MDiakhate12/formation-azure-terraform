resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.prenom}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${var.prenom}"
  kubernetes_version  = var.kubernetes_version

  # Un seul nœud, sans zone : la création ne dépend pas de la capacité d'une zone précise.
  default_node_pool {
    name                        = "system"
    vm_size                     = "Standard_D2as_v6"
    node_count                  = 1
    orchestrator_version        = var.kubernetes_version # les nœuds suivent la version du cluster
    vnet_subnet_id              = azurerm_subnet.aks.id
    temporary_name_for_rotation = "systemtmp"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
  }

  node_provisioning_profile {
    mode = "Manual"
  }

  depends_on = [azurerm_role_assignment.aks_subnet]
}
