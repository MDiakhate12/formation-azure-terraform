# TP2 : variabiliser et nommer

**Objectif** : remplacer les valeurs en dur par des variables, des locals et des outputs. **Durée** : 30 minutes.

## 1. Déclarer les variables

Créez `variables.tf` avec trois variables : `prenom`, `location` et `environment`.

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

À vous : `location`, de type `string`, avec `swedencentral` par défaut.

- `variable` : une entrée du code, dont la valeur est donnée au lancement.
- `type` : le type attendu (`string`, `number`, `bool`, `list(...)`, `map(...)`).
- `default` : la valeur si personne n'en donne. Sans `default`, Terraform la demande.
- `validation` : une règle vérifiée avant le plan. `condition` doit être vraie, sinon `error_message` s'affiche.
- `contains(liste, valeur)` : vrai si la valeur est dans la liste.
- `regex(motif, texte)` : échoue si le texte ne respecte pas le motif. `can(...)` transforme cet échec en `false`.
  Ici : 2 à 12 lettres minuscules, car le prénom finira dans des noms de storage account.

## 2. Calculer un préfixe et nommer

Dans `main.tf` :

```hcl
locals {
  name_prefix = "${var.prenom}-${var.environment}"
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}"
  location = var.location
}
```

- `locals` : des valeurs calculées une fois, réutilisées partout.
- `var.x` : lit une variable. `local.x` : lit un local.
- `"${...}"` : insère une valeur dans une chaîne (interpolation).

## 3. Exposer un résultat

Créez `outputs.tf` :

```hcl
output "resource_group_id" {
  value = azurerm_resource_group.main.id
}
```

- `output` : une valeur affichée à la fin de l'`apply` (et lisible avec `terraform output`).
- `azurerm_resource_group.main.id` : un attribut connu seulement après la création.

## 4. Un fichier de valeurs par environnement

Créez `dev.tfvars` :

```hcl
prenom      = "<prénom>"
environment = "dev"
```

```bash
terraform plan -var-file=dev.tfvars
terraform plan -var-file=dev.tfvars -var="environment=prod"
```

- `-var-file` : charge un fichier de valeurs. `-var` : donne une valeur en ligne de commande.

## 5. Vérifier dans le portail

Lancez `terraform apply -var-file=dev.tfvars`, puis :

1. **Resource groups** (Groupes de ressources) : `rg-<prénom>-tf` a disparu, `rg-<prénom>-dev` l'a remplacé.
2. Ouvrez `rg-<prénom>-dev`, puis **JSON View** (Vue JSON), en haut à droite de la vue d'ensemble.
3. Comparez le champ `id` avec l'output : `terraform output resource_group_id`. C'est la même valeur.

## Questions

- Le plan veut remplacer le resource group du TP1 (`-/+`). Pourquoi ?
- Avec `-var-file` et `-var` à la fois, quelle valeur gagne ?
- Que se passe-t-il si vous oubliez `-var-file` ?

## Pour aller plus loin

Faites échouer la validation volontairement avec `-var="environment=test"` et lisez le message.
