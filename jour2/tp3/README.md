# TP3 : une identité managée avec un rôle

[Sommaire du jour 2](../enonce.md) · [Se connecter à Azure](../enonce.md#avant-de-commencer)

**Objectif** : créer une identité sans mot de passe et lui donner un accès minimal. **Durée** : 40 minutes.
**Dossier de travail** : `jour2/tp3/` (le fichier `versions.tf` y est déjà)

## Où on en est, où on va

Une application qui appelle Azure a besoin d'une identité. Une **identité managée** n'a aucun mot de passe : Azure gère ses jetons.
À la fin de ce TP, vous aurez une identité `id-<prénom>-app` avec un rôle de lecture seule, limité à un seul resource group : le principe du moindre privilège.

## Étape 1 : se placer dans le dossier, reprendre les variables

**À lancer** :

```bash
# Depuis la racine du dépôt cloné
cd jour2/tp3
cp ../tp1/variables.tf ../tp1/dev.tfvars .
```

## Étape 2 : le resource group et l'identité

**À compléter** dans un nouveau fichier `main.tf` :

```hcl
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prenom}-identite"
  location = var.location
}

resource "azurerm_user_assigned_identity" "app" {
  name                = "id-${...}-app"     # À COMPLÉTER : la variable du prénom
  resource_group_name = ...                 # À COMPLÉTER : le nom du resource group (référence)
  location            = ...                 # À COMPLÉTER : la région du resource group (référence)
}
```

## Étape 3 : le rôle, sur le resource group seulement

Un rôle se donne à **qui** (l'identité), pour faire **quoi** (le rôle), **où** (la portée, le `scope`).

**À compléter** à la suite :

```hcl
resource "azurerm_role_assignment" "reader" {
  scope                = ...                                         # À COMPLÉTER : l'id du resource group
  role_definition_name = "..."                                       # À COMPLÉTER : le rôle de lecture seule, Reader
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}
```

> **Explication.**
> - `scope` : la portée. Ici le resource group : l'identité ne verra rien d'autre.
> - `principal_id` : l'identifiant de l'identité dans Microsoft Entra ID, celui à qui l'on donne des rôles.
> - Le rôle à attribuer s'appelle `Lecteur formation` : c'est le rôle Azure `Reader`, sans l'accès aux coûts de la subscription. En entreprise, vous utiliseriez `Reader`.
> - Vous ne pouvez attribuer que `Lecteur formation`, `Contributeur formation`, `Network Contributor`, `AcrPull` et `Storage Blob Data Contributor` : c'est une règle de la formation.

## Étape 4 : les sorties, puis l'apply

**À écrire** dans un nouveau fichier `outputs.tf` : deux outputs, `resource_group_id` (l'id du resource group) et `principal_id` (celui de l'identité).

**À lancer** :

```bash
terraform init
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
# Liste les rôles attribués sur votre resource group
az role assignment list --scope $(terraform output -raw resource_group_id) -o table
```

Sous PowerShell, la dernière commande devient : `az role assignment list --scope (terraform output -raw resource_group_id) -o table`.

**Vérifier** : le plan annonce `3 to add`, et la liste montre le rôle `Lecteur formation` pour votre identité.

## Étape 5 : essayer un rôle interdit

**À faire** : remplacez `"Lecteur formation"` par `"Contributor"`, lancez `terraform apply -var-file=dev.tfvars`, lisez l'erreur, puis remettez `"Lecteur formation"`.

**Vérifier** : l'erreur `AuthorizationFailed` : vous n'avez pas le droit d'attribuer ce rôle.

## Étape 6 : retirer le rôle

**À faire** : supprimez le bloc `azurerm_role_assignment` de `main.tf`.

**À lancer** :

```bash
# Le plan ne doit supprimer que l'attribution de rôle
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

**Vérifier** : le plan annonce `1 to destroy`. L'identité, elle, reste.

## Étape 7 : vérifier dans le portail

1. Ouvrez `rg-<prénom>-identite`, menu **Access control (IAM)** (Contrôle d'accès), onglet **Role assignments** (Attributions de rôles).
2. Avant l'étape 6 : `id-<prénom>-app` y figure avec le rôle `Lecteur formation`. Après : il a disparu.
3. Ouvrez l'identité `id-<prénom>-app` : sa vue d'ensemble affiche son **Client ID** et son **Object (principal) ID**.

## Documentation

- [`azurerm_user_assigned_identity`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity)
- [`azurerm_role_assignment`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)

## Questions

- Où est le mot de passe de cette identité ?
- Quelle différence entre `principal_id` et `client_id` ?

## Pour aller plus loin

Affichez votre **propre** identité.

**À copier** : la première ligne en haut de `main.tf`, l'output à la fin de `outputs.tf`.

```hcl
data "azurerm_client_config" "current" {}
```

```hcl
output "my_object_id" {
  description = "Votre propre identité (pour aller plus loin)"
  value       = data.azurerm_client_config.current.object_id
}
```

---

Précédent : [TP2 : importer et déplacer](../tp2/README.md) · Suivant : [TP4 : premier pipeline](../tp4/README.md) · [Sommaire du jour 2](../enonce.md)
