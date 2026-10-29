# Lus, jamais gérés : créés par le formateur. Les images se tirent sans authentification.
data "azurerm_resource_group" "shared" {
  name = "rg-formation-partage"
}

data "azurerm_container_registry" "acr" {
  name                = "acrformationtf"
  resource_group_name = data.azurerm_resource_group.shared.name
}

module "microservices" {
  source    = "./modules/microservices"
  namespace = kubernetes_namespace_v1.app.metadata[0].name
  prenom    = var.prenom
  registry  = data.azurerm_container_registry.acr.login_server
  tag       = "v1"
  replicas  = 2
}
