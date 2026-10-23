# TP1 : mon premier resource group

**Objectif** : déployer, puis détruire, un resource group avec Terraform. **Durée** : 30 minutes.

## 1. Se connecter

Voir le [README](README.md) : `az login --tenant <tenant>`, puis la variable `ARM_SUBSCRIPTION_ID` (commande différente sous Windows, à refaire dans chaque nouveau terminal).

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

## 5. Retrouver le resource group dans le portail

1. Ouvrez [portal.azure.com](https://portal.azure.com), dans le tenant de la formation (voir le [README](README.md)).
2. Barre de recherche en haut : tapez **Resource groups** (Groupes de ressources), ouvrez le service.
3. Filtrez sur votre prénom : `rg-<prénom>-tf` apparaît, en **Sweden Central**.
4. Ouvrez-le : **Overview** (Vue d'ensemble) est vide, c'est normal, il ne contient encore rien.

## 6. Détruire et recommencer

```bash
terraform destroy    # supprime tout ce que le state connaît
terraform apply      # la même infrastructure revient
```

Actualisez la liste des resource groups entre les deux : le vôtre disparaît, puis revient.

## Documentation

- [`azurerm_resource_group`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)
- [Le provider azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Les commandes Terraform](https://developer.hashicorp.com/terraform/cli/commands)

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

Après l'`apply`, ouvrez le resource group, menu **Tags** (Étiquettes) : `owner` y est.
