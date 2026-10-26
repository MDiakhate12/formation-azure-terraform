terraform {
  backend "azurerm" {
    resource_group_name  = "rg-formateur-tfstate"   # À COMPLÉTER : remplacez <prénom>
    storage_account_name = "stformateurtfstate"     # À COMPLÉTER : remplacez <prénom>
    container_name       = "tfstate"
    key                  = "jour2.tfstate"
  }
}