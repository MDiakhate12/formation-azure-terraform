# TP2 : variabiliser et nommer

**Objectif** : remplacer les valeurs écrites en dur par des variables, des locals et des outputs. **Durée** : 30 minutes.

## Où on en est, où on va

Vous avez un resource group `rg-<prénom>-tf`, mais son nom et sa région sont écrits en dur dans `main.tf`.
À la fin de ce TP, le même code servira à plusieurs environnements : le nom sera calculé à partir de votre prénom et de l'environnement (`rg-<prénom>-dev`).

Vous continuez dans le même dossier qu'au TP1 (`~/formation/jour1`).

## Étape 1 : déclarer les variables

Une variable est une **entrée** du code : sa valeur est donnée au lancement, pas écrite dans le code.

**À copier** dans un nouveau fichier `variables.tf` :

```hcl
variable "prenom" {
  type        = string
  description = "Votre prénom, en minuscules et sans accent : il préfixe toutes vos ressources."

  validation {
    condition     = can(regex("^[a-z]{2,12}$", var.prenom))
    error_message = "2 à 12 lettres minuscules, sans accent ni tiret."
  }
}

variable "environment" {
  type        = string
  description = "Nom de l'environnement"
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Valeurs permises : dev ou prod."
  }
}
```

**À compléter** dans le même fichier, à la suite :

```hcl
variable "location" {
  type        = ...           # À COMPLÉTER : le même type que les deux autres variables
  description = "Région Azure"
  default     = "..."         # À COMPLÉTER : la région de la formation
}
```

> [!NOTE]
> **Explication.**
> - `type` : le type attendu (`string`, `number`, `bool`, `list(...)`, `map(...)`).
> - `default` : la valeur utilisée si personne n'en donne. `prenom` n'en a pas : Terraform devra la recevoir.
> - `validation` : une règle vérifiée avant le plan. Si `condition` est fausse, `error_message` s'affiche.
> - `contains(liste, valeur)` : vrai si la valeur est dans la liste.
> - `regex(motif, texte)` échoue si le texte ne respecte pas le motif, et `can(...)` transforme cet échec en `false`. Ici : 2 à 12 lettres minuscules.

## Étape 2 : calculer le nom, utiliser les variables

Un local est une valeur **calculée** une fois et réutilisée partout.

**À compléter** : remplacez tout le contenu de `main.tf` par :

```hcl
locals {
  name_prefix = "${var.prenom}-${...}"   # À COMPLÉTER : la variable de l'environnement
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}"
  location = ...                         # À COMPLÉTER : la variable de la région, sans guillemets
}
```

> [!NOTE]
> **Explication.**
> - `var.x` lit une variable, `local.x` lit un local.
> - `"${...}"` insère une valeur dans une chaîne : avec `alexandre` et `dev`, `name_prefix` vaut `alexandre-dev`, et le nom devient `rg-alexandre-dev`.
> - Une valeur seule (`var.location`) s'écrit **sans** guillemets : avec des guillemets, ce serait le texte « var.location ».

## Étape 3 : exposer un résultat

Un output affiche une valeur à la fin de l'`apply` : c'est la « sortie » du code.

**À compléter** dans un nouveau fichier `outputs.tf` :

```hcl
output "resource_group_id" {
  value = ...   # À COMPLÉTER : l'id du resource group, sous la forme type.nom.attribut
}
```

> [!NOTE]
> **Explication.** `azurerm_resource_group.main.id` se lit : type de la ressource, puis son nom dans le code, puis l'attribut. L'`id` n'est connu qu'une fois la ressource créée.

## Étape 4 : un fichier de valeurs

Les valeurs des variables se rangent dans un fichier `.tfvars`, un par environnement.

**À compléter** dans un nouveau fichier `dev.tfvars` :

```hcl
prenom      = "<prénom>"   # À COMPLÉTER : votre prénom, par exemple "alexandre"
environment = "dev"
```

> [!NOTE]
> **Explication.** Un `.tfvars` ne contient que des valeurs, pas de code. Terraform ne le lit que si vous le lui indiquez avec `-var-file` (sauf s'il s'appelle exactement `terraform.tfvars`).

## Étape 5 : planifier avec ce fichier

La première commande lit les valeurs de `dev.tfvars`. La seconde donne en plus une valeur directement dans la ligne de commande, pour voir laquelle l'emporte.

**À lancer** :

```bash
# Plan avec les valeurs de dev.tfvars
terraform plan -var-file=dev.tfvars
# Même plan, mais l'environnement est forcé à prod dans la commande
terraform plan -var-file=dev.tfvars -var="environment=prod"
```

**Vérifier** :
- Le premier plan affiche `-/+` et `forces replacement` : le nom passe de `rg-<prénom>-tf` à `rg-<prénom>-dev`.
- Le second affiche `rg-<prénom>-prod`.

## Étape 6 : appliquer et vérifier dans le portail

**À lancer** :

```bash
# Applique avec les valeurs de dev.tfvars (tapez yes)
terraform apply -var-file=dev.tfvars
# Réaffiche les outputs à tout moment
terraform output resource_group_id
```

Dans le portail :

1. **Resource groups** (Groupes de ressources) : `rg-<prénom>-tf` a disparu, `rg-<prénom>-dev` l'a remplacé.
2. Ouvrez `rg-<prénom>-dev`, puis **JSON View** (Vue JSON), en haut à droite de la vue d'ensemble.
3. Le champ `id` est le même que celui affiché par `terraform output`.

À partir de maintenant, ajoutez toujours `-var-file=dev.tfvars` à `plan` et `apply`.

## Documentation

- [Les variables](https://developer.hashicorp.com/terraform/language/values/variables)
- [Les locals](https://developer.hashicorp.com/terraform/language/values/locals)
- [Les outputs](https://developer.hashicorp.com/terraform/language/values/outputs)

## Questions

- Le plan veut remplacer le resource group du TP1 (`-/+`). Pourquoi ?
- Avec `-var-file` et `-var` à la fois, quelle valeur gagne ?
- Que se passe-t-il si vous oubliez `-var-file` ?

## Pour aller plus loin

Faites échouer la validation volontairement, puis lisez le message :

```bash
# environment=test n'est pas dans la liste autorisée
terraform plan -var-file=dev.tfvars -var="environment=test"
```
