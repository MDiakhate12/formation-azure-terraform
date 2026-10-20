terraform {
  required_version = ">= 1.15.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
  }

  # State partagé du formateur. La clé est propre à chacun :
  # terraform init -backend-config="key=<prénom>.tfstate"
  backend "azurerm" {
    resource_group_name  = "rg-formation-partage"
    storage_account_name = "stformationtfstates"
    container_name       = "pannes"
  }
}
