resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prenom}-j3"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.prenom}-j3"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.42.0.0/16"]
}

# Les pods prennent leurs adresses dans un réseau overlay : le sous-réseau n'accueille que les nœuds.
resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.42.1.0/24"]
}
