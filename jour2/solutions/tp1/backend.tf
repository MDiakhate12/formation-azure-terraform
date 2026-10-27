# Ajouté après le premier apply, puis : terraform init -migrate-state
# Le bloc backend n'accepte pas de variables : remplacez "prenom".
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-prenom-tfstate"
    storage_account_name = "stprenomtfstate"
    container_name       = "tfstate"
    key                  = "jour2.tfstate"
  }
}
