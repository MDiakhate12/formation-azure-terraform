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
