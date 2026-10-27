# TP1 : un state distant

[Sommaire du jour 2](../enonce.md) · [Se connecter à Azure](../enonce.md#avant-de-commencer)

**Objectif** : créer avec Terraform le stockage du state, puis y déplacer le state. **Durée** : 15 minutes.
**Dossier de travail** : `jour2/tp1/` (le fichier `versions.tf` y est déjà)

## Où on en est, où on va

Hier, le state vivait dans un fichier `terraform.tfstate` sur votre poste : personne d'autre ne pouvait travailler sur votre infrastructure, et le perdre, c'était perdre la mémoire de Terraform.
À la fin de ce TP, votre state sera dans un compte de stockage Azure, partagé et protégé par un **verrou** pendant chaque `apply`.

## Étape 1 : se placer dans le dossier, déclarer les variables

**À lancer** :

```bash
# Depuis la racine du dépôt cloné
cd jour2/tp1
```

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

variable "location" {
  type    = string
  default = "swedencentral"
}
```

**À compléter** dans un nouveau fichier `dev.tfvars` :

```hcl
prenom = "<prénom>"   # À COMPLÉTER : votre prénom, par exemple "alexandre"
```

## Étape 2 : le stockage du state

Un state distant a besoin de trois ressources : un resource group, un compte de stockage, et un conteneur (un « dossier » de fichiers, appelés blobs).

**À compléter** dans un nouveau fichier `main.tf` :

```hcl
resource "azurerm_resource_group" "state" {
  name     = "rg-${var.prenom}-tfstate"
  location = var.location
}

resource "azurerm_storage_account" "state" {
  name                      = "st${var.prenom}tfstate"
  resource_group_name       = ...                     # À COMPLÉTER : le nom du resource group (référence)
  location                  = ...                     # À COMPLÉTER : la région du resource group (référence)
  account_tier              = "Standard"
  account_replication_type  = "..."                   # À COMPLÉTER : LRS, la réplication la moins chère
  shared_access_key_enabled = true
}

resource "azurerm_storage_container" "state" {
  name                  = "tfstate"
  storage_account_id    = ...                         # À COMPLÉTER : l'id du compte de stockage
  container_access_type = "private"
}
```

> **Explication.**
> - Le nom d'un compte de stockage est **unique dans tout Azure** : 3 à 24 caractères, minuscules et chiffres uniquement. D'où le prénom sans accent ni tiret.
> - `LRS` : trois copies dans un seul centre de données. Suffisant pour un TP.
> - `shared_access_key_enabled = true` : Terraform pourra lire et écrire le state avec la clé du compte.
> - `container_access_type = "private"` : le state peut contenir des secrets, il ne doit jamais être public.

Pour info:
* LRS : Protège contre une panne de disque/serveur. (Le moins cher)
* ZRS : Protège contre la perte d'un bâtiment.
* GRS : Protège contre la perte d'une région entière.
* GZRS : Protection maximale sur tous les niveaux. (Le plus cher)

**À écrire** dans un nouveau fichier `outputs.tf` : un output `storage_account_name` qui affiche le nom du compte de stockage.

## Étape 3 : créer le stockage, avec un state encore local

**À lancer** :

```bash
# Télécharge le provider (nouveau dossier, donc nouvel init)
terraform init
terraform plan -var-file=dev.tfvars
# Crée le stockage (tapez yes)
terraform apply -var-file=dev.tfvars
# Le state est encore un fichier local
ls terraform.tfstate
```

**Vérifier** : le plan annonce `3 to add`, et le fichier `terraform.tfstate` existe dans le dossier.

Erreur `StorageAccountAlreadyTaken` ? Quelqu'un dans le monde a déjà ce nom : ajoutez deux chiffres après votre prénom dans `main.tf` (`st${var.prenom}42tfstate`), et reportez-les dans `backend.tf` à l'étape suivante.

## Étape 4 : déclarer le backend

Le **backend** dit à Terraform où ranger son state.

**À compléter** dans un nouveau fichier `backend.tf` :

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-<prénom>-tfstate"   # À COMPLÉTER : remplacez <prénom>
    storage_account_name = "st<prénom>tfstate"     # À COMPLÉTER : remplacez <prénom>
    container_name       = "tfstate"
    key                  = "jour2.tfstate"
  }
}
```

> **Explication.**
> - Un bloc `backend` **n'accepte pas de variables** : les valeurs sont écrites en dur, d'où `<prénom>` à remplacer à la main.
> - `key` : le nom du fichier du state dans le conteneur.
> - Le stockage doit exister **avant** d'y ranger le state : c'est pour cela qu'on l'a créé à l'étape 3, avec un state local.

## Étape 5 : déplacer le state

`-migrate-state` copie le state local vers le nouveau backend.

**À lancer** :

```bash
# Relit la configuration du backend et propose de copier le state : répondez yes
terraform init -migrate-state
# Liste les fichiers du conteneur : jour2.tfstate doit y être
az storage blob list --account-name st<prénom>tfstate -c tfstate --auth-mode key -o table
```

**Vérifier** : le blob `jour2.tfstate` apparaît. `terraform plan -var-file=dev.tfvars` annonce `No changes` : rien n'a été perdu.

## Étape 6 : provoquer un verrou

Le verrou empêche deux personnes d'écrire le même state en même temps.

**À lancer**, dans **deux terminaux** placés dans `jour2/tp1/` :

```bash
# Terminal 1 : lancez apply et NE répondez PAS à la question
terraform apply -var-file=dev.tfvars
```

```bash
# Terminal 2, pendant que le terminal 1 attend : un plan
terraform plan -var-file=dev.tfvars
```

**Vérifier** : le terminal 2 affiche `Error acquiring the state lock`, avec l'auteur du verrou. Répondez ensuite `no` dans le terminal 1 : le verrou est levé.

## Étape 7 : retrouver le state dans le portail

1. Ouvrez `rg-<prénom>-tfstate`, puis le compte de stockage `st<prénom>tfstate`.
2. Menu **Data storage > Containers** (Stockage des données > Conteneurs), conteneur `tfstate` : le blob `jour2.tfstate` est là.
3. Relancez le verrou de l'étape 6 et actualisez : la colonne **Lease state** (État du bail) passe à `Leased` pendant l'`apply`.

## Documentation

- [Le backend azurerm](https://developer.hashicorp.com/terraform/language/backend/azurerm)
- [`azurerm_storage_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
- [`azurerm_storage_container`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container)

## Questions

- Où se trouve maintenant le fichier `terraform.tfstate` local ? Que contient-il ?
- Quel message affiche le second terminal pendant le verrou ?

## Pour aller plus loin

**À lancer** :

```bash
# Liste les ressources connues du state, puis le détail de l'une d'elles
terraform state list
terraform state show azurerm_storage_account.state
```

---

Suivant : [TP2 : importer et déplacer](../tp2/README.md) · [Sommaire du jour 2](../enonce.md)
