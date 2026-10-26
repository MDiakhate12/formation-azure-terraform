# Bonus : un pipeline sans secret (OIDC)

[Sommaire du jour 2](../enonce.md) · [Se connecter à Azure](../enonce.md#avant-de-commencer)

**Objectif** : laisser GitHub Actions se connecter à Azure **sans aucun secret**, grâce à la fédération d'identité. **Durée** : 30 minutes.
**Dossier de travail** : `jour2/bonus/` (les fichiers `versions.tf`, `azure-oidc.yml` et `terraform-ci.yml` y sont déjà)

## Où on en est, où on va

Au TP4, le job `plan` avait besoin d'un secret, à renouveler et à protéger.
Ici, Azure fait **confiance** aux jetons émis par GitHub pour votre dépôt : plus aucun secret. Ce bonus réunit le TP3 (identité managée) et le TP4 (pipeline), avec le dépôt GitHub du TP4.

## Étape 1 : les variables, et le « subject » de votre dépôt

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

## Étape 2 : l'identité et sa fédération

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

**À écrire** à la fin : une `azurerm_role_assignment` nommée `reader`, qui donne `Lecteur formation` à l'identité sur son resource group (comme au TP3).

> **Explication.**
> - `issuer` : qui émet les jetons, ici GitHub. `audience` : à qui ils sont destinés, ici Azure.
> - `subject` : **de quel dépôt et de quelle branche** le jeton doit venir. Deux identités fédérées : une pour `main`, une pour les pull requests.

## Étape 3 : les sorties, puis l'apply

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

## Étape 4 : les variables du dépôt GitHub

**À faire** : dans votre dépôt `tp-pipeline`, **Settings > Secrets and variables > Actions**, onglet **Variables**, créez `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` et `RESOURCE_GROUP` avec les valeurs de l'output. Ce ne sont **pas** des secrets.

## Étape 5 : le workflow

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

## Questions

- `az group list` dans le pipeline : combien de resource groups voit l'identité ? Pourquoi ?
- Que se passe-t-il si vous lancez le workflow depuis une autre branche que `main` ?
- Pour aller plus loin : pourquoi le state du pipeline ne peut-il pas rester local ?
- Pourquoi l'identité du pipeline ne peut-elle rien créer hors de `rg-<prénom>-oidc` ?

## Pour aller plus loin : plan et apply depuis le pipeline

Le pipeline se connecte à Azure sans secret. Faisons-lui maintenant **exécuter Terraform** : `plan` sur chaque pull request, `apply` après fusion sur `main`.

### Étape A : donner au pipeline les droits de créer

Aujourd'hui, l'identité n'a que `Lecteur formation`. Il lui faut deux droits de plus, et rien d'autre : créer dans **son** resource group, et lire et écrire **son** state, dans le conteneur partagé `oidc`.

**À copier** dans un nouveau fichier `pipeline.tf`, dans `jour2/bonus/` :

```hcl
resource "azurerm_role_assignment" "pipeline_contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Contributeur formation"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}

data "azurerm_storage_account" "states" {
  name                = "stformationtfstates"
  resource_group_name = "rg-formation-partage"
}

resource "azurerm_role_assignment" "pipeline_state" {
  scope                = "${data.azurerm_storage_account.states.id}/blobServices/default/containers/oidc"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}
```

**À lancer** : `terraform apply -var-file=dev.tfvars`. **Vérifier** : `2 to add`.

> **Explication.**
> - « Contributeur formation » est le rôle Contributor de la formation : il crée et modifie, ici **dans un seul resource group**.
> - `Storage Blob Data Contributor` donne accès aux **données** des blobs, ici sur un seul conteneur : de quoi verrouiller, lire et écrire un state, sans pouvoir toucher au compte de stockage lui-même.
> - Le moindre privilège : la plus petite portée qui suffit.

### Étape B : le code que le pipeline va appliquer

Dans votre dépôt `tp-pipeline`, créez un dossier `ci/`.

**À compléter** dans un nouveau fichier `ci/main.tf` :

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }

  # Le runner GitHub repart de zéro à chaque exécution : le state doit être distant
  backend "azurerm" {
    resource_group_name  = "rg-formation-partage"
    storage_account_name = "stformationtfstates"
    container_name       = "oidc"
    key                  = "<prénom>.tfstate"       # À COMPLÉTER : votre prénom
  }
}

provider "azurerm" {
  features {}
}

# Une ressource gratuite, créée par le pipeline dans le seul resource group où il a des droits
resource "azurerm_user_assigned_identity" "depuis_github" {
  name                = "id-<prénom>-depuis-github"   # À COMPLÉTER : votre prénom
  resource_group_name = "rg-<prénom>-oidc"            # À COMPLÉTER : votre prénom
  location            = "swedencentral"
}
```

> **Explication.** Rien ne dit ici « connecte-toi par OIDC » : ce sont les variables d'environnement du workflow (`ARM_USE_OIDC`, `ARM_USE_AZUREAD`) qui l'activent. Sur votre poste, le même code utilise votre session `az`.

### Étape C : le workflow

**À lancer**, depuis `jour2/bonus/` :

```bash
# Copie le workflow fourni et le code dans votre dépôt, sur une nouvelle branche
cp terraform-ci.yml ../../../tp-pipeline/.github/workflows/
cd ../../../tp-pipeline
git checkout -b ci-terraform
git add .github/workflows/terraform-ci.yml ci/main.tf
git commit -m "Terraform exécuté par le pipeline"
git push origin ci-terraform
```

Ouvrez une **pull request** de `ci-terraform` vers `main`.

**Vérifier** :
1. Dans la pull request, le job `plan` affiche `1 to add`, sans aucun secret configuré.
2. Fusionnez : sur `main`, le job `apply` crée `id-<prénom>-depuis-github`. Retrouvez-le dans `rg-<prénom>-oidc`.

## Pour finir

Le pipeline a créé une ressource que votre state local ne connaît pas : détruisez-la **en premier**, sinon le `destroy` du resource group échoue.

**À lancer**, si vous avez fait le « Pour aller plus loin » :

```bash
# Depuis votre dépôt tp-pipeline : même backend que le pipeline, avec votre session az
cd ci
terraform init
terraform destroy
```

**À lancer** ensuite, de retour dans `jour2/bonus/` :

```bash
terraform destroy -var-file=dev.tfvars
```

---

Précédent : [TP5 : mon cluster AKS](../tp5/README.md) · Suivant : [Bonus 2 : une infrastructure en équipe](../bonus2/README.md) · [Sommaire du jour 2](../enonce.md)
