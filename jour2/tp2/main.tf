data "azurerm_subscription" "current" {}

import {
  to = azurerm_resource_group.manuel
  id = "${data.azurerm_subscription.current.id}/resourceGroups/rg-${var.prenom}-manuel"   # À COMPLÉTER : la variable du prénom
}

resource "azurerm_resource_group" "manuel" {
  name     = "rg-${var.prenom}-manuel"
  location = var.location # À COMPLÉTER : la variable de la région
}

moved {
  from = azurerm_resource_group.legacy # À COMPLÉTER : l'ancienne adresse, azurerm_resource_group puis l'ancien nom du bloc
  to   = azurerm_resource_group.manuel # À COMPLÉTER : la nouvelle adresse, avec le nouveau nom
}

data "azurerm_resource_group" "shared" {
  name = "rg-formation-partage"
}