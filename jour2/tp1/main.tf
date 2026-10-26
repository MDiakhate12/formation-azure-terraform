resource "azurerm_resource_group" "state" {
  name     = "rg-${var.prenom}-tfstate"
  location = var.location
}

resource "azurerm_storage_account" "state" {
  name                      = "st${var.prenom}tfstate"
  resource_group_name       = azurerm_resource_group.state.name                     # À COMPLÉTER : le nom du resource group (référence)
  location                  = azurerm_resource_group.state.location                     # À COMPLÉTER : sa région (référence)
  account_tier              = "Standard"
  account_replication_type  = "LRS"                   # À COMPLÉTER : LRS, la réplication la moins chère
  shared_access_key_enabled = true
}

resource "azurerm_storage_container" "state" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.state.id                         # À COMPLÉTER : l'id du compte de stockage
  container_access_type = "private"
}
