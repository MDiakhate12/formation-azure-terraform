# Les droits du pipeline : créer dans son resource group, lire et écrire son state. Rien d'autre.
resource "azurerm_role_assignment" "pipeline_contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Contributeur formation"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}

data "azurerm_storage_account" "states" {
  name                = "stformationtfstates"
  resource_group_name = "rg-formation-partage"
}

resource "azurerm_role_assignment" "pipeline_state" {
  scope                = "${data.azurerm_storage_account.states.id}/blobServices/default/containers/oidc"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}
