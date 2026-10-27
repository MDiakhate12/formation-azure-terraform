terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }

  # Le runner GitHub repart de zéro à chaque exécution : le state doit être distant.
  # L'authentification OIDC vient des variables d'environnement du workflow : le même code marche depuis votre poste.
  backend "azurerm" {
    resource_group_name  = "rg-formation-partage"
    storage_account_name = "stformationtfstates"
    container_name       = "oidc"
    key                  = "prenom.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Créée par le pipeline, dans le seul resource group où il a des droits.
resource "azurerm_user_assigned_identity" "depuis_github" {
  name                = "id-prenom-depuis-github"
  resource_group_name = "rg-prenom-oidc"
  location            = "swedencentral"
}
