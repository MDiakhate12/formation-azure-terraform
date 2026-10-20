# Identité du cluster créée à l'avance : elle reçoit ses droits sur le sous-réseau avant la création du cluster.
resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-${var.prenom}-aks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_role_assignment" "aks_subnet" {
  scope                = azurerm_subnet.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.prenom}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${var.prenom}"
  kubernetes_version  = var.kubernetes_version

  # Un seul nœud, sans zone : la B2s_v2 n'est pas disponible dans toutes les zones de westeurope.
  default_node_pool {
    name                        = "system"
    vm_size                     = "Standard_B2s_v2"
    node_count                  = 1
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
