# Remplacez "prenom" par votre prénom (minuscules, sans accent).
resource "azurerm_resource_group" "main" {
  name     = "rg-prenom-tf"
  location = "swedencentral"
}
