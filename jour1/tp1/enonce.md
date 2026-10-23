# TP1 : mon premier resource group

**Objectif** : créer, puis détruire, un resource group avec Terraform. **Durée** : 30 minutes.
Avant de commencer, lisez la partie [Lire les énoncés](../README.md#lire-les-énoncés) : elle explique les repères **À copier**, **À compléter**, **À lancer** et la notation `<prénom>`.

## Où on en est, où on va

Rien n'existe encore. À la fin de ce TP, vous aurez créé un resource group `rg-<prénom>-tf` dans Azure, uniquement avec du code.
C'est le premier maillon du fil rouge : tout le réseau de la journée viendra s'y ranger.

## Étape 1 : préparer votre dossier et vous connecter

Terraform lit tous les fichiers `.tf` du dossier où vous le lancez : chaque projet a donc son dossier.

**À lancer** (macOS, Linux, Git Bash) :

```bash
# Crée votre dossier de travail pour la journée
mkdir -p ~/formation/jour1
# Vous place dedans : toutes les commandes du jour se lancent ici
cd ~/formation/jour1
```

Sous Windows PowerShell : `mkdir -Force $HOME\formation\jour1` puis `cd $HOME\formation\jour1`.

Connectez-vous ensuite avec le bloc du [README](../README.md#avant-de-commencer) (`az login`, puis la variable `ARM_SUBSCRIPTION_ID`).

**Vérifier** : `echo $ARM_SUBSCRIPTION_ID` (ou `$env:ARM_SUBSCRIPTION_ID` sous PowerShell) affiche un identifiant.

Ouvrez ce dossier dans VS Code : `code .`

## Étape 2 : déclarer Terraform et le provider

Terraform ne connaît aucun cloud : il lui faut un plugin, le **provider**, pour parler à Azure.

**À copier** dans un nouveau fichier `versions.tf` :

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

> [!NOTE]
> **Explication.**
> - `terraform { }` : les réglages de Terraform lui-même. `required_version` : la version minimale acceptée.
> - `required_providers` : les plugins à télécharger. `source` dit où les trouver, `version` lesquelles accepter (`~> 5.0` : toute version 5.x, jamais 6.0).
> - `provider "azurerm"` : la connexion à Azure. `features {}` est obligatoire, même vide. La subscription est lue dans `ARM_SUBSCRIPTION_ID`.

## Étape 3 : décrire le resource group

Un resource group est un conteneur : il range des ressources qui vivent et meurent ensemble.

**À compléter** dans un nouveau fichier `main.tf` :

```hcl
resource "azurerm_resource_group" "main" {
  name     = "rg-<prénom>-tf"   # À COMPLÉTER : remplacez <prénom>, par exemple rg-alexandre-tf
  location = "..."              # À COMPLÉTER : la seule région autorisée, swedencentral
}
```

> [!NOTE]
> **Explication.**
> - `resource` : une ressource que Terraform crée et gère.
> - `"azurerm_resource_group"` : son type, fourni par le provider. `"main"` : son nom **dans le code**, pour y faire référence plus tard.
> - `name` : son nom **dans Azure**, celui que vous verrez dans le portail. `location` : sa région.

## Étape 4 : le cycle de vie Terraform

Ces cinq commandes reviendront dans tous les TP. Lancez-les une par une et lisez ce qu'elles affichent.

**À lancer** :

```bash
# Télécharge le provider azurerm dans le dossier .terraform/ (une fois par dossier)
terraform init
# Remet le code en forme : indentation, alignement des =
terraform fmt
# Vérifie la syntaxe, sans contacter Azure
terraform validate
# Montre ce que Terraform va faire, sans rien changer
terraform plan
# Fait réellement les changements : tapez yes pour confirmer
terraform apply
```

**Vérifier** :
- `plan` annonce `Plan: 1 to add, 0 to change, 0 to destroy`.
- `apply` se termine par `Apply complete! Resources: 1 added`.

Erreur `RequestDisallowedByPolicy` ? La région n'est pas `swedencentral` (attention à l'orthographe exacte) : la policy de la formation la refuse.

## Étape 5 : retrouver le resource group dans le portail

1. Ouvrez [portal.azure.com](https://portal.azure.com), dans le tenant de la formation (voir le [README](../README.md#le-portail-azure)).
2. Barre de recherche en haut : tapez **Resource groups** (Groupes de ressources), ouvrez le service.
3. Filtrez sur votre prénom : `rg-<prénom>-tf` apparaît, en **Sweden Central**.
4. Ouvrez-le : **Overview** (Vue d'ensemble) est vide, c'est normal, il ne contient encore rien.

## Étape 6 : détruire et recommencer

**À lancer** :

```bash
# Supprime tout ce que Terraform a créé dans ce dossier (tapez yes)
terraform destroy
# Recrée exactement la même infrastructure, à partir du même code
terraform apply
```

**Vérifier** : actualisez la liste des resource groups entre les deux commandes. Le vôtre disparaît, puis revient.
Gardez-le : le TP2 part de lui.

## Documentation

- [`azurerm_resource_group`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)
- [Le provider azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Les commandes Terraform](https://developer.hashicorp.com/terraform/cli/commands)

## Questions

- Qu'a créé `terraform init` dans votre dossier ?
- Dans le plan, que signifie le symbole `+` ?

## Pour aller plus loin

Ajoutez un tag au resource group, puis lancez `terraform plan` : quel symbole apparaît ?

**À copier** dans le bloc `azurerm_resource_group`, sous `location` :

```hcl
  tags = {
    owner = "<prénom>"
  }
```

Après l'`apply`, ouvrez le resource group, menu **Tags** (Étiquettes) : `owner` y est.
