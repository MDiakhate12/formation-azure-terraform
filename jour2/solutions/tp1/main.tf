resource "azurerm_resource_group" "state" {
  name     = "rg-${var.prenom}-tfstate"
  location = var.location
}

# Nom unique dans tout Azure : 3 à 24 minuscules et chiffres.
resource "azurerm_storage_account" "state" {
  name                      = "st${var.prenom}tfstate"
  resource_group_name       = azurerm_resource_group.state.name
  location                  = azurerm_resource_group.state.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  shared_access_key_enabled = true
}

resource "azurerm_storage_container" "state" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.state.id
  container_access_type = "private"
}
