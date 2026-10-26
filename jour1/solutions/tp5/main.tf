resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prenom}-reseau"
  location = var.location
}

module "network_dev" {
  source              = "./modules/network"
  prefix              = "dev"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.10.0.0/16"]
  subnets = {
    app  = "10.10.1.0/24"
    data = "10.10.2.0/24"
  }
}

module "network_prod" {
  source              = "./modules/network"
  prefix              = "prod"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.20.0.0/16"]
  subnets = {
    app  = "10.20.1.0/24"
    data = "10.20.2.0/24"
  }
}
