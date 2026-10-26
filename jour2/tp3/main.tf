resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prenom}-identite"
  location = var.location
}

resource "azurerm_user_assigned_identity" "app" {
  name                = "id-${var.prenom}-app"     # À COMPLÉTER : la variable du prénom
  resource_group_name = azurerm_resource_group.main.name                 # À COMPLÉTER : le nom du resource group (référence)
  location            = azurerm_resource_group.main.location                 # À COMPLÉTER : sa région (référence)
}

resource "azurerm_role_assignment" "reader" {
  scope = azurerm_resource_group.main.id
  role_definition_name = "Reader"
  principal_id = azurerm_user_assigned_identity.app.principal_id
}