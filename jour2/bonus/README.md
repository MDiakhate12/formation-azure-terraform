# Bonus : un pipeline sans secret (OIDC)

[Sommaire du jour 2](../enonce.md) · [Se connecter à Azure](../enonce.md#avant-de-commencer)

**Objectif** : laisser GitHub Actions se connecter à Azure **sans aucun secret**, grâce à la fédération d'identité. **Durée** : 30 minutes.
**Dossier de travail** : `jour2/bonus/` (les fichiers `versions.tf` et `azure-oidc.yml` y sont déjà)

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

**À écrire** à la fin : une `azurerm_role_assignment` nommée `reader`, qui donne `Reader` à l'identité sur son resource group (comme au TP3).

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

## Pour finir

**À lancer**, de retour dans `jour2/bonus/` :

```bash
terraform destroy -var-file=dev.tfvars
```

---

Précédent : [TP5 : mon cluster AKS](../tp5/README.md) · [Sommaire du jour 2](../enonce.md)
