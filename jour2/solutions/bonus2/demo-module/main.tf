# Démonstration du formateur : le même lakehouse, déployé depuis l'URL git du dépôt d'équipe, avec un state local.
terraform {
  required_version = ">= 1.15.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "demo" {
  name     = "rg-formateur-module-sql"
  location = "swedencentral"
}

module "lakehouse" {
  # ref=v1 : la version taguée du module. Sans ref, on suivrait la branche main et ses changements.
  source = "git::https://github.com/MDiakhate12/formation-equipe-sql.git//modules/sql?ref=v1"

  prefix              = "formateur-demo-26"
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  sql_admin_login     = "formateur"
  sql_admin_object_id = "06aaff22-647d-46fa-9500-11c61a949f2f"
}

output "server_fqdn" {
  value = module.lakehouse.server_fqdn
}
