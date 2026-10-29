resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.prenom}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${var.prenom}"

  # Bonus : 1.35 puis 1.36. Le canal patch applique ensuite les correctifs tout seul.
  kubernetes_version        = var.kubernetes_version
  automatic_upgrade_channel = "patch"

  default_node_pool {
    name                        = "system"
    vm_size                     = "Standard_D2as_v6"
    orchestrator_version        = var.kubernetes_version # les nœuds suivent la version du cluster
    vnet_subnet_id              = azurerm_subnet.aks.id
    temporary_name_for_rotation = "systemtmp"

    # TP3 : l'autoscaler remplace node_count. Maximum 2 pour le quota de la formation.
    auto_scaling_enabled = true
    min_count            = 1
    max_count            = 2

    # TP3 : tags Azure (facturation) et labels Kubernetes (placement des pods).
    tags = {
      owner = var.prenom
    }
    node_labels = {
      role = "system"
    }

    upgrade_settings {
      max_surge = "10%"
    }
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
