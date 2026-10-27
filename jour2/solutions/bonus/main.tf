data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prenom}-oidc"
  location = var.location
}

resource "azurerm_user_assigned_identity" "github" {
  name                = "id-${var.prenom}-github"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

# Azure fait confiance aux jetons émis par GitHub pour ce dépôt : aucun secret à stocker.
locals {
  github_subjects = {
    main         = "${var.github_subject}:ref:refs/heads/main"
    pull-request = "${var.github_subject}:pull_request"
  }
}

resource "azurerm_federated_identity_credential" "github" {
  for_each = local.github_subjects

  name                      = "github-${each.key}"
  user_assigned_identity_id = azurerm_user_assigned_identity.github.id
  issuer                    = "https://token.actions.githubusercontent.com"
  audience                  = ["api://AzureADTokenExchange"]
  subject                   = each.value
}

resource "azurerm_role_assignment" "reader" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Lecteur formation"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}
