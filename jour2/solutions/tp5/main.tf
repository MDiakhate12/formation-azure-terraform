resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prenom}-aks"
  location = var.location
}

# Un seul nœud, sans zone : la création ne dépend pas de la capacité d'une zone précise.
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.prenom}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${var.prenom}"

  default_node_pool {
    name       = "system"
    vm_size    = "Standard_D2as_v6"
    node_count = var.node_count
  }

  identity {
    type = "SystemAssigned"
  }

  # Obligatoire en azurerm 5 : Manual = pools de nœuds déclarés par nous (Auto = provisionnement automatique).
  node_provisioning_profile {
    mode = "Manual"
  }
}
