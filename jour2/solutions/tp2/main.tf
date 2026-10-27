data "azurerm_subscription" "current" {}

# Le resource group a été créé à la main : az group create -n rg-<prénom>-manuel -l swedencentral
# Le bloc import a été supprimé à l'étape 4. Vous repartez de cette solution sans state ? Décommentez-le.
# import {
#   to = azurerm_resource_group.manuel
#   id = "${data.azurerm_subscription.current.id}/resourceGroups/rg-${var.prenom}-manuel"
# }

# Renommage dans le code sans recréation : l'ancienne adresse était azurerm_resource_group.legacy.
moved {
  from = azurerm_resource_group.legacy
  to   = azurerm_resource_group.manuel
}

resource "azurerm_resource_group" "manuel" {
  name     = "rg-${var.prenom}-manuel"
  location = var.location
}

# Lu, jamais géré : créé par le formateur.
data "azurerm_resource_group" "shared" {
  name = "rg-formation-partage"
}
