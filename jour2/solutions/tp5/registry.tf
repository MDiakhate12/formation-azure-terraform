# Écrit pendant la création du cluster : lu, jamais géré.
data "azurerm_container_registry" "shared" {
  name                = "acrformationtf"
  resource_group_name = "rg-formation-partage"
}
