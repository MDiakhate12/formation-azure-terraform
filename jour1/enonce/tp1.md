# TP1 : mon premier resource group

**Objectif** : déployer, puis détruire, un resource group avec Terraform. **Durée** : 30 minutes.

## 1. Se connecter

Voir le [README](README.md) : `az login --tenant <tenant>`, puis `export ARM_SUBSCRIPTION_ID=...`.

## 2. Déclarer Terraform et le provider

Dans votre dossier de travail, créez `versions.tf` :

```hcl
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
```

- `terraform { }` : les réglages de Terraform lui-même.
- `required_version` : la version minimale de Terraform acceptée.
- `required_providers` : les plugins à télécharger. `source` dit où le trouver, `version` lesquelles accepter (`~> 5.0` : toute 5.x, jamais 6.0).
- `provider "azurerm"` : la connexion à Azure. `features {}` est obligatoire, même vide. La subscription est lue dans `ARM_SUBSCRIPTION_ID`.

## 3. Décrire le resource group

Créez `main.tf` :

```hcl
resource "azurerm_resource_group" "main" {
  name     = "rg-<prénom>-tf"
  location = "swedencentral"
}
```

- `resource` : une ressource que Terraform crée et gère.
- `"azurerm_resource_group"` : son type (fourni par le provider). `"main"` : son nom dans le code, pour y faire référence.
- `name`, `location` : les arguments. `name` est le nom réel dans Azure : mettez votre prénom.

## 4. Le cycle de vie

```bash
terraform init       # télécharge le provider dans .terraform/
terraform fmt        # remet le code en forme
terraform validate   # vérifie la syntaxe, sans appeler Azure
terraform plan       # montre ce qui va changer, sans rien faire
terraform apply      # applique, après votre "yes"
```

Retrouvez votre resource group dans le portail Azure.

## 5. Détruire et recommencer

```bash
terraform destroy    # supprime tout ce que le state connaît
terraform apply      # la même infrastructure revient
```

## Questions

- Qu'a créé `terraform init` dans votre dossier ?
- Dans le plan, que signifie le symbole `+` ?

## Pour aller plus loin

Ajoutez un tag et lisez le plan : quel symbole apparaît ?

```hcl
  tags = {
    owner = "<prénom>"
  }
```
