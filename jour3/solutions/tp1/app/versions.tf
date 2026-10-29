terraform {
  required_version = ">= 1.15.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
  }
}

# La subscription est lue dans ARM_SUBSCRIPTION_ID.
provider "azurerm" {
  features {}
}
