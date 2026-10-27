data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prenom}-identite"
  location = var.location
}

resource "azurerm_user_assigned_identity" "app" {
  name                = "id-${var.prenom}-app"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_role_assignment" "reader" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Lecteur formation"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}
