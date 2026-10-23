# Jour 2 : énoncé

Chaque TP est autonome et a son dossier dans le dépôt cloné : travaillez directement dedans (`cd jour2/tp1`). Le fichier `versions.tf` y est déjà. Rien ne dépend du travail d'hier.
Vos fichiers ne sont pas suivis par git : `git pull` ne les touche pas.
Bloqué ? La solution de chaque TP est publiée juste après sa correction dans `jour2/solutions/tpN/` : `git pull`, puis copiez-la dans le dossier du TP.

## Lire les énoncés

Les mêmes repères qu'au jour 1 :

| Repère | Ce que vous faites |
|---|---|
| **À copier** | Recopiez le bloc tel quel dans le fichier indiqué. |
| **À compléter** | Recopiez le bloc, puis remplacez chaque `...` : le commentaire `# À COMPLÉTER : ...` dit quoi mettre. |
| **À écrire** | Écrivez le bloc vous-même, à partir de la consigne. |
| **À lancer** | Tapez les commandes dans le terminal, dans le dossier de travail du TP. La ligne `#` au-dessus dit ce que fait chaque commande. |
| **Vérifier** | Ce que vous devez obtenir. Sinon, arrêtez-vous et demandez. |

> [!NOTE]
> **Explication.** Ces encadrés expliquent le code : à lire, rien à faire.

Tout ce qui est entre chevrons `< >` est à remplacer, chevrons compris : `rg-<prénom>-tfstate` devient `rg-alexandre-tfstate`.

## Avant de commencer

### macOS, Linux, Git Bash

```bash
az login --tenant <tenant>
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo $ARM_SUBSCRIPTION_ID
```

### Windows PowerShell

```powershell
az login --tenant <tenant>
$env:ARM_SUBSCRIPTION_ID = (az account show --query id -o tsv)
$env:ARM_SUBSCRIPTION_ID
```

La dernière ligne doit afficher un identifiant (`xxxxxxxx-xxxx-...`).

> **À refaire dans chaque nouveau terminal.** La variable n'existe que dans le terminal où vous l'avez définie.
> Nouvel onglet, nouvelle fenêtre, terminal de VS Code : relancez la ligne `export` (ou `$env:...`). `az login` n'est pas à refaire.
> Si vous l'oubliez, `terraform plan` échoue avec : `subscription_id is a required provider property`.

Pour ne plus y penser, ajoutez-la au démarrage de vos terminaux (à retirer après la formation) :

- macOS (zsh) : `echo 'export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)' >> ~/.zshrc`
- Windows : `setx ARM_SUBSCRIPTION_ID (az account show --query id -o tsv)`, valable pour les **prochains** terminaux uniquement.

Rappels : préfixe par votre prénom, région `swedencentral`, taille `Standard_D2as_v6`, **aucune zone** sur les nœuds.

## Sommaire

| TP | Sujet | Durée |
|---|---|---|
| [TP1](#tp1--un-state-distant) | Un state distant | 30 min |
| [TP2](#tp2--importer-et-déplacer) | Importer et déplacer | 30 min |
| [TP3](#tp3--une-identité-managée-avec-un-rôle) | Une identité managée avec un rôle | 40 min |
| [TP4](#tp4--premier-pipeline) | Premier pipeline | 30 min |
| [TP5](#tp5--mon-cluster-aks) | Mon cluster AKS | 50 min |
| [Bonus](#bonus--un-pipeline-sans-secret-oidc) | Un pipeline sans secret (OIDC) | 30 min |

**Avant de partir** : `terraform destroy` sur le cluster du TP5. Il coûte à l'heure, et demain le code du cluster est fourni.

## TP1 : un state distant

**Objectif** : créer avec Terraform le stockage du state, puis y déplacer le state. **Durée** : 30 minutes.
**Dossier de travail** : `jour2/tp1/` (le fichier `versions.tf` y est déjà)

### Où on en est, où on va

Hier, le state vivait dans un fichier `terraform.tfstate` sur votre poste : personne d'autre ne pouvait travailler sur votre infrastructure, et le perdre, c'était perdre la mémoire de Terraform.
À la fin de ce TP, votre state sera dans un compte de stockage Azure, partagé et protégé par un **verrou** pendant chaque `apply`.

### Étape 1 : se placer dans le dossier, déclarer les variables

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

### Étape 2 : le stockage du state

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
  location                  = ...                     # À COMPLÉTER : sa région (référence)
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

> [!NOTE]
> **Explication.**
> - Le nom d'un compte de stockage est **unique dans tout Azure** : 3 à 24 caractères, minuscules et chiffres uniquement. D'où le prénom sans accent ni tiret.
> - `LRS` : trois copies dans un seul centre de données. Suffisant pour un TP.
> - `shared_access_key_enabled = true` : Terraform pourra lire et écrire le state avec la clé du compte.
> - `container_access_type = "private"` : le state peut contenir des secrets, il ne doit jamais être public.

**À écrire** dans un nouveau fichier `outputs.tf` : un output `storage_account_name` qui affiche le nom du compte de stockage.

### Étape 3 : créer le stockage, avec un state encore local

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

### Étape 4 : déclarer le backend

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

> [!NOTE]
> **Explication.**
> - Un bloc `backend` **n'accepte pas de variables** : les valeurs sont écrites en dur, d'où `<prénom>` à remplacer à la main.
> - `key` : le nom du fichier du state dans le conteneur.
> - Le stockage doit exister **avant** d'y ranger le state : c'est pour cela qu'on l'a créé à l'étape 3, avec un state local.

### Étape 5 : déplacer le state

`-migrate-state` copie le state local vers le nouveau backend.

**À lancer** :

```bash
# Relit la configuration du backend et propose de copier le state : répondez yes
terraform init -migrate-state
# Liste les fichiers du conteneur : jour2.tfstate doit y être
az storage blob list --account-name st<prénom>tfstate -c tfstate --auth-mode key -o table
```

**Vérifier** : le blob `jour2.tfstate` apparaît. `terraform plan -var-file=dev.tfvars` annonce `No changes` : rien n'a été perdu.

### Étape 6 : provoquer un verrou

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

### Étape 7 : retrouver le state dans le portail

1. Ouvrez `rg-<prénom>-tfstate`, puis le compte de stockage `st<prénom>tfstate`.
2. Menu **Data storage > Containers** (Stockage des données > Conteneurs), conteneur `tfstate` : le blob `jour2.tfstate` est là.
3. Relancez le verrou de l'étape 6 et actualisez : la colonne **Lease state** (État du bail) passe à `Leased` pendant l'`apply`.

### Documentation

- [Le backend azurerm](https://developer.hashicorp.com/terraform/language/backend/azurerm)
- [`azurerm_storage_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
- [`azurerm_storage_container`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container)

### Questions

- Où se trouve maintenant le fichier `terraform.tfstate` local ? Que contient-il ?
- Quel message affiche le second terminal pendant le verrou ?

### Pour aller plus loin

**À lancer** :

```bash
# Liste les ressources connues du state, puis le détail de l'une d'elles
terraform state list
terraform state show azurerm_storage_account.state
```

## TP2 : importer et déplacer

**Objectif** : faire adopter par Terraform une ressource créée à la main, puis la renommer dans le code sans la recréer. **Durée** : 30 minutes.
**Dossier de travail** : `jour2/tp2/` (le fichier `versions.tf` y est déjà)

### Où on en est, où on va

En entreprise, beaucoup de ressources existent déjà, créées à la main dans le portail. Terraform ne les connaît pas.
À la fin de ce TP, vous aurez fait **adopter** un resource group existant par Terraform (`import`), puis vous l'aurez renommé dans le code sans le détruire (`moved`).

### Étape 1 : se placer dans le dossier, reprendre les variables

**À lancer** :

```bash
# Depuis la racine du dépôt cloné
cd jour2/tp2
# Reprend les variables et les valeurs du TP1
cp ../tp1/variables.tf ../tp1/dev.tfvars .
```

### Étape 2 : créer une ressource à la main

On simule une ressource créée hors de Terraform, comme un collègue l'aurait fait dans le portail.

**À lancer** :

```bash
# Crée un resource group avec la CLI Azure, sans Terraform
az group create -n rg-<prénom>-manuel -l swedencentral
```

### Étape 3 : décrire la ressource et l'importer

Pour adopter une ressource, il faut deux choses : le bloc `resource` qui la décrit, et un bloc `import` qui donne son identifiant Azure.

**À compléter** dans un nouveau fichier `main.tf` :

```hcl
data "azurerm_subscription" "current" {}

import {
  to = azurerm_resource_group.legacy
  id = "${data.azurerm_subscription.current.id}/resourceGroups/rg-${...}-manuel"   # À COMPLÉTER : la variable du prénom
}

resource "azurerm_resource_group" "legacy" {
  name     = "rg-${var.prenom}-manuel"
  location = ...                                                                     # À COMPLÉTER : la variable de la région
}
```

> [!NOTE]
> **Explication.**
> - `data "azurerm_subscription" "current"` **lit** la subscription courante, sans rien créer. Son `id` vaut `/subscriptions/<id>`.
> - `import` : `to` est l'adresse dans le code, `id` l'identifiant de la ressource dans Azure. Rien n'est importé avant l'`apply` : vous pouvez lire le plan d'abord.
> - Le bloc `resource` doit décrire la ressource **telle qu'elle est** : sinon le plan proposera de la modifier.

**À lancer** :

```bash
terraform init
# Le plan doit annoncer une importation, aucune création
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

**Vérifier** : le plan annonce `1 to import, 0 to add, 0 to change, 0 to destroy`.

### Étape 4 : renommer dans le code, sans recréer

Le nom `legacy` ne vous plaît plus : vous voulez `manuel`. Renommer un bloc fait croire à Terraform qu'une ressource disparaît et qu'une autre apparaît.

**À faire** dans `main.tf` :
1. Renommez le bloc `resource "azurerm_resource_group" "legacy"` en `"manuel"`.
2. Dans le bloc `import`, remplacez `to = azurerm_resource_group.legacy` par `to = azurerm_resource_group.manuel`.

**À compléter** à la suite, dans `main.tf` :

```hcl
moved {
  from = ...   # À COMPLÉTER : l'ancienne adresse, azurerm_resource_group puis l'ancien nom du bloc
  to   = ...   # À COMPLÉTER : la nouvelle adresse, avec le nouveau nom
}
```

> [!NOTE]
> **Explication.** `moved` dit à Terraform : « c'est la même ressource, elle a seulement changé d'adresse dans le code ». Le bloc `import` peut rester : il est ignoré pour une ressource déjà dans le state.

**À lancer** :

```bash
# Le plan doit annoncer un déplacement, sans destruction
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

**Vérifier** : le plan affiche `has moved to azurerm_resource_group.manuel` et `0 to add, 0 to change, 0 to destroy`.

### Étape 5 : lire une ressource qu'on ne gère pas

Un `data` lit une ressource existante sans jamais la modifier : ici, le resource group partagé créé par le formateur.

**À écrire** à la fin de `main.tf` : un `data "azurerm_resource_group" "shared"` dont le `name` est `rg-formation-partage`.

**À compléter** dans un nouveau fichier `outputs.tf` :

```hcl
output "manuel_id" {
  value = ...                                      # À COMPLÉTER : l'id du resource group importé
}

output "shared_resource_group" {
  value = {
    id       = data.azurerm_resource_group.shared.id
    location = ...                                 # À COMPLÉTER : la région du resource group partagé
  }
}
```

**À lancer** :

```bash
terraform apply -var-file=dev.tfvars
```

**Vérifier** : les deux outputs s'affichent, avec `swedencentral` comme région du resource group partagé.

### Étape 6 : vérifier dans le portail

1. **Resource groups** (Groupes de ressources) : `rg-<prénom>-manuel` existe toujours, avec la même date de création : il n'a jamais été recréé.
2. `rg-formation-partage` est visible, mais il n'apparaît pas dans `terraform state list` : Terraform ne fait que le lire.

### Documentation

- [Le bloc `import`](https://developer.hashicorp.com/terraform/language/import)
- [Le bloc `moved`](https://developer.hashicorp.com/terraform/language/modules/develop/refactoring)
- [Data source `azurerm_resource_group`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group)

### Questions

- Que se passerait-il au `plan` de l'étape 4 sans le bloc `moved` ?
- Pourquoi `apply` ne détruira jamais `rg-formation-partage` ?

### Pour aller plus loin

Supprimez le bloc `resource` et laissez Terraform l'écrire à votre place :

```bash
# Écrit dans generated.tf le code de la ressource à importer
terraform plan -var-file=dev.tfvars -generate-config-out=generated.tf
```

## TP3 : une identité managée avec un rôle

**Objectif** : créer une identité sans mot de passe et lui donner un accès minimal. **Durée** : 40 minutes.
**Dossier de travail** : `jour2/tp3/` (le fichier `versions.tf` y est déjà)

### Où on en est, où on va

Une application qui appelle Azure a besoin d'une identité. Une **identité managée** n'a aucun mot de passe : Azure gère ses jetons.
À la fin de ce TP, vous aurez une identité `id-<prénom>-app` avec le rôle `Reader`, limité à un seul resource group : le principe du moindre privilège.

### Étape 1 : se placer dans le dossier, reprendre les variables

**À lancer** :

```bash
# Depuis la racine du dépôt cloné
cd jour2/tp3
cp ../tp1/variables.tf ../tp1/dev.tfvars .
```

### Étape 2 : le resource group et l'identité

**À compléter** dans un nouveau fichier `main.tf` :

```hcl
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prenom}-identite"
  location = var.location
}

resource "azurerm_user_assigned_identity" "app" {
  name                = "id-${...}-app"     # À COMPLÉTER : la variable du prénom
  resource_group_name = ...                 # À COMPLÉTER : le nom du resource group (référence)
  location            = ...                 # À COMPLÉTER : sa région (référence)
}
```

### Étape 3 : le rôle, sur le resource group seulement

Un rôle se donne à **qui** (l'identité), pour faire **quoi** (le rôle), **où** (la portée, le `scope`).

**À compléter** à la suite :

```hcl
resource "azurerm_role_assignment" "reader" {
  scope                = ...                                         # À COMPLÉTER : l'id du resource group
  role_definition_name = "..."                                       # À COMPLÉTER : le rôle de lecture seule, Reader
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}
```

> [!NOTE]
> **Explication.**
> - `scope` : la portée. Ici le resource group : l'identité ne verra rien d'autre.
> - `principal_id` : l'identifiant de l'identité dans Microsoft Entra ID, celui à qui l'on donne des rôles.
> - Vous ne pouvez attribuer que les rôles `Reader`, `Network Contributor` et `AcrPull` : c'est une règle de la formation.

### Étape 4 : les sorties, puis l'apply

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

**Vérifier** : le plan annonce `3 to add`, et la liste montre le rôle `Reader` pour votre identité.

### Étape 5 : essayer un rôle interdit

**À faire** : remplacez `"Reader"` par `"Contributor"`, lancez `terraform apply -var-file=dev.tfvars`, lisez l'erreur, puis remettez `"Reader"`.

**Vérifier** : l'erreur `AuthorizationFailed` : vous n'avez pas le droit d'attribuer ce rôle.

### Étape 6 : retirer le rôle

**À faire** : supprimez le bloc `azurerm_role_assignment` de `main.tf`.

**À lancer** :

```bash
# Le plan ne doit supprimer que l'attribution de rôle
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

**Vérifier** : le plan annonce `1 to destroy`. L'identité, elle, reste.

### Étape 7 : vérifier dans le portail

1. Ouvrez `rg-<prénom>-identite`, menu **Access control (IAM)** (Contrôle d'accès), onglet **Role assignments** (Attributions de rôles).
2. Avant l'étape 6 : `id-<prénom>-app` y figure avec le rôle `Reader`. Après : il a disparu.
3. Ouvrez l'identité `id-<prénom>-app` : sa vue d'ensemble affiche son **Client ID** et son **Object (principal) ID**.

### Documentation

- [`azurerm_user_assigned_identity`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity)
- [`azurerm_role_assignment`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)

### Questions

- Où est le mot de passe de cette identité ?
- Quelle différence entre `principal_id` et `client_id` ?

### Pour aller plus loin

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

## TP4 : premier pipeline

**Objectif** : faire vérifier votre code Terraform automatiquement, à chaque pull request. **Durée** : 30 minutes.
**Dossier de travail** : votre propre dépôt GitHub, cloné **en dehors** du dépôt de la formation

### Où on en est, où on va

Jusqu'ici, c'est vous qui lancez `fmt` et `validate`, quand vous y pensez.
À la fin de ce TP, GitHub Actions les lancera tout seul à chaque pull request, et bloquera un code mal formaté. C'est la première brique d'un pipeline CI/CD.

### Étape 1 : un dépôt GitHub avec un peu de Terraform

**À faire** sur [github.com](https://github.com) : créez un dépôt **vide** à vous (bouton **New**), par exemple `tp-pipeline`.

**À lancer**, depuis le dossier **parent** du dépôt de la formation (pas dedans) :

```bash
# Clone votre nouveau dépôt, à côté de celui de la formation
git clone https://github.com/<votre-compte>/tp-pipeline.git
cd tp-pipeline
# Y copie du code Terraform : la solution du TP2 d'hier
cp ../formation-azure-terraform/jour1/solutions/tp2/*.tf .
```

**Vérifier** : `ls` affiche `main.tf`, `outputs.tf`, `variables.tf` et `versions.tf`.

### Étape 2 : le workflow

Un **workflow** GitHub Actions est un fichier YAML dans `.github/workflows/` : il dit quand se déclencher et quelles commandes lancer.

**À lancer** :

```bash
# Crée le dossier attendu par GitHub
mkdir -p .github/workflows
```

**À compléter** dans un nouveau fichier `.github/workflows/terraform.yml` :

```yaml
name: terraform

on:
  pull_request:
  push:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: hashicorp/setup-terraform@v4
        with:
          terraform_version: "~1.16"
      - run: terraform fmt -check -recursive
      - run: terraform init -backend=false
      - run: terraform ...                  # À COMPLÉTER : la commande qui vérifie la syntaxe
```

> [!NOTE]
> **Explication.**
> - `on` : quand le workflow se déclenche. Ici, à chaque pull request et à chaque push sur `main`.
> - `runs-on: ubuntu-latest` : une machine Linux fournie par GitHub, effacée à la fin.
> - `actions/checkout` récupère votre code ; `hashicorp/setup-terraform` installe Terraform.
> - `fmt -check` **échoue** si le code n'est pas formaté, sans rien modifier. `init -backend=false` télécharge les providers sans toucher à aucun state.

### Étape 3 : envoyer le code et ouvrir une pull request

**À lancer** :

```bash
# Crée une branche de travail
git checkout -b ajout-pipeline
# Prépare tous les fichiers pour le commit
git add .
git commit -m "Code Terraform et pipeline de vérification"
# Envoie la branche sur GitHub
git push -u origin ajout-pipeline
```

**À faire** sur GitHub : la page du dépôt propose **Compare & pull request** : ouvrez la pull request.

**Vérifier** : onglet **Actions**, le workflow `terraform` tourne, puis passe au vert.

### Étape 4 : casser le format, voir le pipeline échouer

**À faire** : dans `main.tf`, décalez une ligne avec des espaces en trop.

**À lancer** :

```bash
git commit -am "Format cassé exprès"
git push
```

**Vérifier** : le pipeline passe au **rouge** sur l'étape `terraform fmt -check`. Corrigez :

```bash
# Remet le code en forme, puis renvoie la correction
terraform fmt
git commit -am "Format corrigé"
git push
```

### Documentation

- [Automatiser Terraform avec GitHub Actions](https://developer.hashicorp.com/terraform/tutorials/automation/github-actions)
- [La syntaxe des workflows](https://docs.github.com/actions/writing-workflows/workflow-syntax-for-github-actions)

### Questions

- Pourquoi `-backend=false` ?
- Le pipeline parle-t-il à Azure ? De quoi aurait-il besoin pour un `plan` ?

### Pour aller plus loin

Ajoutez un job `plan`, qui se connecte à Azure avec un service principal.

1. **À copier** : le contenu de `jour2/tp4/plan-job.yml` (dépôt de la formation), à la fin de votre `terraform.yml`, sous `jobs:`.
2. **À faire** : dans votre dépôt GitHub, **Settings > Secrets and variables > Actions**, créez les quatre secrets `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID` et `ARM_SUBSCRIPTION_ID`. Le formateur vous les donne.

## TP5 : mon cluster AKS

**Objectif** : créer un cluster Kubernetes managé à un nœud, s'y connecter, puis le détruire. **Durée** : 50 minutes.
**Dossier de travail** : `jour2/tp5/` (le fichier `versions.tf` y est déjà)

### Où on en est, où on va

AKS est le Kubernetes managé d'Azure : Azure gère le plan de contrôle, vous gérez les nœuds (des VM) et ce qui tourne dessus.
À la fin de ce TP, vous aurez créé un cluster `aks-<prénom>`, vous y serez connecté avec `kubectl`, et vous l'aurez détruit. Demain, le code du cluster est fourni : il recréera le même.

### Étape 1 : se placer dans le dossier, déclarer les variables

**À lancer** :

```bash
# Depuis la racine du dépôt cloné
cd jour2/tp5
cp ../tp1/variables.tf ../tp1/dev.tfvars .
```

**À écrire** à la fin de `variables.tf` : une variable `node_count`, de type `number`, avec `1` par défaut.

### Étape 2 : le cluster

**À compléter** dans un nouveau fichier `main.tf` :

```hcl
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prenom}-aks"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.prenom}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${...}"                 # À COMPLÉTER : la variable du prénom

  default_node_pool {
    name       = "system"
    vm_size    = "..."                               # À COMPLÉTER : la seule taille autorisée, Standard_D2as_v6
    node_count = ...                                 # À COMPLÉTER : la variable de l'étape 1
  }

  identity {
    type = "SystemAssigned"
  }

  node_provisioning_profile {
    mode = "Manual"
  }
}
```

> [!NOTE]
> **Explication.**
> - `default_node_pool` : le groupe de nœuds système. Pas d'argument `zones` : la création ne dépend pas de la capacité d'une zone précise.
> - `identity { type = "SystemAssigned" }` : le cluster reçoit sa propre identité managée, pour créer ses disques et ses IP.
> - `node_provisioning_profile { mode = "Manual" }` : obligatoire avec azurerm 5. `Manual` : c'est vous qui déclarez les pools de nœuds.

### Étape 3 : lancer la création tout de suite

La création prend 5 à 10 minutes : lancez-la maintenant, vous écrirez la suite pendant l'attente.

**À lancer** :

```bash
terraform init
# Lisez le plan, puis tapez yes : la création démarre
terraform apply -var-file=dev.tfvars
```

**Vérifier** : le plan annonce `2 to add`. Laissez ce terminal tourner et passez à l'étape 4.

### Étape 4 : pendant l'attente, lire le registre et préparer les sorties

**À écrire** dans un nouveau fichier `registry.tf` : un `data "azurerm_container_registry" "shared"` qui lit le registre `acrformationtf` du resource group `rg-formation-partage`.

**À compléter** dans un nouveau fichier `outputs.tf` :

```hcl
output "get_credentials" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
}

output "kubernetes_version" {
  value = ...                                        # À COMPLÉTER : l'attribut kubernetes_version du cluster
}

output "registry_login_server" {
  value = ...                                        # À COMPLÉTER : le login_server du registre lu par le data
}
```

Une fois le premier `apply` terminé, **à lancer** :

```bash
# Ajoute la lecture du registre et les outputs : aucune ressource créée
terraform apply -var-file=dev.tfvars
```

**Vérifier** : `0 to add`, puis les trois outputs s'affichent, dont la version de Kubernetes et `acrformationtf.azurecr.io`.

### Étape 5 : se connecter au cluster

**À lancer** :

```bash
# Affiche la commande qui écrit les accès du cluster dans ~/.kube/config
terraform output -raw get_credentials
# Copiez-collez la commande affichée, puis :
kubectl get nodes
kubectl get pods -A
```

**Vérifier** : `kubectl get nodes` affiche un nœud `Ready`, et `get pods -A` les pods système de Kubernetes.

### Étape 6 : lire un changement sans l'appliquer

**À lancer** :

```bash
# Plan avec deux nœuds au lieu d'un : on lit, on n'applique pas
terraform plan -var-file=dev.tfvars -var="node_count=2"
```

**Vérifier** : le plan affiche `~` (modification en place) : le cluster ne serait pas recréé.

### Étape 7 : retrouver le cluster dans le portail

1. Ouvrez `rg-<prénom>-aks`, puis `aks-<prénom>` : la vue d'ensemble affiche la version de Kubernetes et l'état `Succeeded`.
2. Menu **Settings > Node pools** (Paramètres > Pools de nœuds) : le pool `system`, 1 nœud, `Standard_D2as_v6`.
3. Cherchez le resource group `MC_rg-<prénom>-aks_aks-<prénom>_swedencentral` : AKS l'a créé seul, il contient les VM des nœuds.

### Étape 8 : détruire le cluster

Un cluster coûte à l'heure, même sans rien faire.

**À lancer** :

```bash
# Supprime le cluster et son resource group (tapez yes) : quelques minutes
terraform destroy -var-file=dev.tfvars
```

### Documentation

- [`azurerm_kubernetes_cluster`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)
- [Data source `azurerm_container_registry`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/container_registry)

### Questions

- Dans quel resource group Azure a-t-il placé les VM des nœuds ?
- Le passage à 2 nœuds recrée-t-il le cluster ?

### Pour aller plus loin

Ajoutez un pool `user`, **avant** le `destroy`.

**À lancer** :

```bash
# Le modèle fourni devient un fichier Terraform actif
mv node-pool.tf.bonus node-pool.tf
terraform apply -var-file=dev.tfvars
```

Il double vos vCPU : détruisez-le dès que vous l'avez vu (`terraform destroy -var-file=dev.tfvars`).

## Bonus : un pipeline sans secret (OIDC)

**Objectif** : laisser GitHub Actions se connecter à Azure **sans aucun secret**, grâce à la fédération d'identité. **Durée** : 30 minutes.
**Dossier de travail** : `jour2/bonus/` (les fichiers `versions.tf` et `azure-oidc.yml` y sont déjà)

### Où on en est, où on va

Au TP4, le job `plan` avait besoin d'un secret, à renouveler et à protéger.
Ici, Azure fait **confiance** aux jetons émis par GitHub pour votre dépôt : plus aucun secret. Ce bonus réunit le TP3 (identité managée) et le TP4 (pipeline), avec le dépôt GitHub du TP4.

### Étape 1 : les variables, et le « subject » de votre dépôt

Azure n'accepte que les jetons d'un dépôt précis, reconnu par son **subject** : `repo:<propriétaire>@<id>/<dépôt>@<id>`.

**À faire** : ouvrez `https://api.github.com/repos/<votre-compte>/tp-pipeline` dans le navigateur. Notez le premier `"id"` (le dépôt) et celui de la partie `"owner"` (vous).

**À lancer** :

```bash
cd jour2/bonus
cp ../tp1/variables.tf ../tp1/dev.tfvars .
```

**À copier** à la fin de `variables.tf` :

```hcl
variable "github_subject" {
  type        = string
  description = "Début du subject OIDC de votre dépôt, lu dans le log de azure/login : repo:<propriétaire>@<id>/<dépôt>@<id>"

  validation {
    condition     = can(regex("^repo:[^:]+$", var.github_subject))
    error_message = "Format attendu : repo:<propriétaire>@<id>/<dépôt>@<id>, sans :ref ni :pull_request."
  }
}
```

**À compléter** à la fin de `dev.tfvars` :

```hcl
github_subject = "repo:<votre-compte>@<id du compte>/tp-pipeline@<id du dépôt>"   # À COMPLÉTER : vos trois valeurs
```

Pas sûr des identifiants ? Lancez le workflow de l'étape 5 une première fois : son échec affiche le `subject` exact.

### Étape 2 : l'identité et sa fédération

**À copier** en haut d'un nouveau fichier `main.tf` :

```hcl
data "azurerm_client_config" "current" {}
```

**À écrire** à la suite, comme au TP3 : un resource group `"rg-${var.prenom}-oidc"` (nommé `main` dans le code) et une identité managée `"id-${var.prenom}-github"` (nommée `github`).

**À compléter** à la suite :

```hcl
locals {
  github_subjects = {
    main         = "${var.github_subject}:ref:refs/heads/main"
    pull-request = "${var.github_subject}:..."     # À COMPLÉTER : pull_request
  }
}

resource "azurerm_federated_identity_credential" "github" {
  for_each = local.github_subjects

  name                      = "github-${each.key}"
  user_assigned_identity_id = azurerm_user_assigned_identity.github.id
  issuer                    = "https://token.actions.githubusercontent.com"
  audience                  = ["api://AzureADTokenExchange"]
  subject                   = ...                   # À COMPLÉTER : la valeur de l'élément courant
}
```

**À écrire** à la fin : une `azurerm_role_assignment` nommée `reader`, qui donne `Reader` à l'identité sur son resource group (comme au TP3).

> [!NOTE]
> **Explication.**
> - `issuer` : qui émet les jetons, ici GitHub. `audience` : à qui ils sont destinés, ici Azure.
> - `subject` : **de quel dépôt et de quelle branche** le jeton doit venir. Deux identités fédérées : une pour `main`, une pour les pull requests.

### Étape 3 : les sorties, puis l'apply

**À copier** dans un nouveau fichier `outputs.tf` :

```hcl
output "github_variables" {
  description = "À créer comme variables (pas des secrets) du dépôt GitHub"
  value = {
    AZURE_CLIENT_ID       = azurerm_user_assigned_identity.github.client_id
    AZURE_TENANT_ID       = data.azurerm_client_config.current.tenant_id
    AZURE_SUBSCRIPTION_ID = data.azurerm_client_config.current.subscription_id
    RESOURCE_GROUP        = azurerm_resource_group.main.name
  }
}
```

**À lancer** :

```bash
terraform init
terraform apply -var-file=dev.tfvars
```

**Vérifier** : le plan annonce `5 to add`, puis l'output `github_variables` affiche quatre valeurs.

### Étape 4 : les variables du dépôt GitHub

**À faire** : dans votre dépôt `tp-pipeline`, **Settings > Secrets and variables > Actions**, onglet **Variables**, créez `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` et `RESOURCE_GROUP` avec les valeurs de l'output. Ce ne sont **pas** des secrets.

### Étape 5 : le workflow

**À lancer** :

```bash
# Copie le workflow fourni dans votre dépôt du TP4, puis l'envoie sur main
cp azure-oidc.yml ../../../tp-pipeline/.github/workflows/
cd ../../../tp-pipeline
git add .github/workflows/azure-oidc.yml
git commit -m "Connexion Azure par OIDC"
git push origin HEAD:main
```

**Vérifier** : onglet **Actions**, le workflow `azure-oidc` passe au vert et affiche votre resource group. Aucun secret n'est stocké dans GitHub.

### Questions

- `az group list` dans le pipeline : combien de resource groups voit l'identité ? Pourquoi ?
- Que se passe-t-il si vous lancez le workflow depuis une autre branche que `main` ?

### Pour finir

**À lancer**, de retour dans `jour2/bonus/` :

```bash
terraform destroy -var-file=dev.tfvars
```
