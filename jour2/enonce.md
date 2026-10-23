# Jour 2 : énoncé

Chaque TP est autonome et a son dossier dans le dépôt cloné : travaillez directement dedans (`cd jour2/tp1`). Le fichier `versions.tf` y est déjà. Rien ne dépend du travail d'hier.
Vos fichiers ne sont pas suivis par git : `git pull` ne les touche pas.
Bloqué ? La solution de chaque TP est publiée juste après sa correction dans `jour2/solutions/tpN/` : `git pull`, puis copiez-la dans le dossier du TP.

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

**Objectif** : créer le stockage du state avec Terraform, puis y migrer le state. **Durée** : 30 minutes.
**Dossier de travail** : `jour2/tp1/`

### Étapes

1. Déclarez les variables `prenom` et `location`, puis créez :
   - un resource group `rg-<prénom>-tfstate` ;
   - un `azurerm_storage_account` nommé `st<prénom>tfstate` (Standard, LRS, `shared_access_key_enabled = true`) ;
   - un `azurerm_storage_container` privé `tfstate`, rattaché au compte par `storage_account_id`.
2. `terraform init`, puis `apply`. Le state est encore local : repérez `terraform.tfstate`.
3. Ajoutez `backend.tf` avec un bloc `backend "azurerm"` (`resource_group_name`, `storage_account_name`, `container_name`, `key = "jour2.tfstate"`). Les valeurs sont écrites en dur : un backend n'accepte pas de variables.
4. `terraform init -migrate-state`, répondez `yes`.
5. Vérifiez le blob :
   `az storage blob list --account-name st<prénom>tfstate -c tfstate --auth-mode key -o table`
6. Provoquez un verrou : lancez `terraform apply` dans un terminal et, sans répondre, `terraform plan` dans un second.

Nom déjà pris (`StorageAccountAlreadyTaken`) ? Le nom est unique dans tout Azure : ajoutez deux chiffres.

### Questions

- Où se trouve maintenant le fichier `terraform.tfstate` local ? Que contient-il ?
- Quel message affiche le second terminal pendant le verrou ?

### Pour aller plus loin

`terraform state list`, puis `terraform state show azurerm_storage_account.state`.


## TP2 : importer et déplacer

**Objectif** : faire adopter une ressource existante par Terraform, puis la renommer sans la recréer. **Durée** : 30 minutes.
**Dossier de travail** : `jour2/tp2/`

### Étapes

1. Créez un resource group à la main :
   `az group create -n rg-<prénom>-manuel -l swedencentral`
2. Écrivez :
   - un bloc `resource "azurerm_resource_group" "legacy"` qui décrit ce resource group ;
   - un bloc `import` vers `azurerm_resource_group.legacy`. Son `id` est de la forme
     `/subscriptions/<id>/resourceGroups/rg-<prénom>-manuel` : construisez-le avec `data.azurerm_subscription.current.id`.
3. `plan` : le plan doit annoncer **1 to import**, 0 to add. Puis `apply`.
4. Renommez la ressource en `azurerm_resource_group.manuel`, ajoutez un bloc `moved` et mettez à jour le `to` du bloc `import`.
   Le plan doit annoncer 0 to add, 0 to destroy.
5. Lisez le resource group partagé `rg-formation-partage` avec un `data` et affichez son id et sa région en output.

### Questions

- Que se passerait-il au `plan` de l'étape 4 sans le bloc `moved` ?
- Pourquoi `apply` ne détruira jamais `rg-formation-partage` ?

### Pour aller plus loin

Supprimez le bloc `resource` et laissez Terraform l'écrire : `terraform plan -generate-config-out=generated.tf`.


## TP3 : une identité managée avec un rôle

**Objectif** : créer une identité sans mot de passe et lui donner un accès minimal. **Durée** : 40 minutes.
**Dossier de travail** : `jour2/tp3/`

### Étapes

1. Créez un resource group `rg-<prénom>-identite`.
2. Créez une `azurerm_user_assigned_identity` nommée `id-<prénom>-app`.
3. Attribuez-lui le rôle `Reader` **sur ce resource group seulement** (`azurerm_role_assignment`, `scope` = id du resource group).
4. Affichez son `principal_id` en output, puis `apply`.
5. Vérifiez : `az role assignment list --scope <id du resource group> -o table`.
6. Retirez le bloc `azurerm_role_assignment` du code : que dit le plan ? Appliquez, puis vérifiez à nouveau.

Vous ne pouvez attribuer que les rôles Reader, Network Contributor et AcrPull : c'est voulu.
Essayez `Contributor` à la place de `Reader` et lisez l'erreur.

### Questions

- Où est le mot de passe de cette identité ?
- Quelle différence entre `principal_id` et `client_id` ?

### Pour aller plus loin

Affichez votre propre `object_id` avec `data "azurerm_client_config" "current"`.


## TP4 : premier pipeline

**Objectif** : faire tourner `fmt`, `init` et `validate` automatiquement sur une pull request. **Durée** : 30 minutes.
**Dossier de travail** : votre propre dépôt GitHub (voir les étapes)

Il vous faut un dépôt GitHub à vous, avec un peu de Terraform dedans (par exemple votre TP2 d'hier, ou `jour1/solutions/tp2`).

### Étapes

1. Créez `.github/workflows/terraform.yml` avec un job `validate` sur `ubuntu-latest` :
   - déclenché sur `pull_request` et sur `push` vers `main` ;
   - étapes `actions/checkout@v7`, `hashicorp/setup-terraform@v4` ;
   - puis `terraform fmt -check -recursive`, `terraform init -backend=false`, `terraform validate`.
2. Poussez sur une branche et ouvrez une pull request.
3. Suivez l'exécution dans l'onglet **Actions**.
4. Cassez le format d'un fichier (indentation), poussez : le pipeline doit échouer. Corrigez avec `terraform fmt`.

### Questions

- Pourquoi `-backend=false` ?
- Le pipeline parle-t-il à Azure ? De quoi aurait-il besoin pour un `plan` ?

### Pour aller plus loin

Ajoutez un job `plan` (modèle dans `jour2/tp4/plan-job.yml`) avec les quatre secrets `ARM_*` fournis par le formateur.


## TP5 : mon cluster AKS

**Objectif** : créer un cluster AKS à un nœud, s'y connecter, puis le détruire. **Durée** : 50 minutes.
**Dossier de travail** : `jour2/tp5/`

### Étapes

1. Créez un resource group `rg-<prénom>-aks`, puis `aks.tf` :
   - `azurerm_kubernetes_cluster` nommé `aks-<prénom>`, `dns_prefix` identique ;
   - `default_node_pool` : `name = "system"`, `vm_size = "Standard_D2as_v6"`, `node_count = 1`, **sans** `zones` ;
   - `identity { type = "SystemAssigned" }` ;
   - `node_provisioning_profile { mode = "Manual" }`, obligatoire en azurerm 5.
2. `apply` **tout de suite** : la création prend 5 à 10 minutes.
3. Pendant l'attente, lisez le registre partagé avec `data "azurerm_container_registry"` (`acrformationtf` dans `rg-formation-partage`) et affichez son `login_server`.
4. Connectez-vous :
   `az aks get-credentials --resource-group rg-<prénom>-aks --name aks-<prénom>`, puis `kubectl get nodes` et `kubectl get pods -A`.
5. Passez `node_count` à 2 : **lisez** le plan, puis répondez `no`.
6. `terraform destroy`.

### Questions

- Dans quel resource group Azure a-t-il placé les VM des nœuds ?
- Le passage à 2 nœuds recrée-t-il le cluster ?

### Pour aller plus loin

Ajoutez un pool `user` avec `azurerm_kubernetes_cluster_node_pool` (modèle dans `jour2/tp5/node-pool.tf.bonus`). Il double vos vCPU : détruisez-le vite.


## Bonus : un pipeline sans secret (OIDC)

**Objectif** : laisser GitHub Actions se connecter à Azure sans aucun secret, grâce à la fédération d'identité. **Durée** : 30 minutes.
**Dossier de travail** : `jour2/bonus/`
Il réunit le TP3 (identité managée) et le TP4 (pipeline). Il vous faut un dépôt GitHub à vous.

### Étapes

1. Créez un resource group `rg-<prénom>-oidc` et une identité managée `id-<prénom>-github`.
2. Ajoutez deux `azurerm_federated_identity_credential` sur cette identité (`user_assigned_identity_id`) :
   - `issuer = "https://token.actions.githubusercontent.com"`, `audience = ["api://AzureADTokenExchange"]` ;
   - `subject` : `<début>:ref:refs/heads/main`, puis `<début>:pull_request`.
     GitHub met dans `<début>` les identifiants numériques du propriétaire et du dépôt : `repo:<propriétaire>@<id>/<dépôt>@<id>`.
     Pour les connaître : `curl -s https://api.github.com/repos/<propriétaire>/<dépôt>`, champs `owner.id` et `id`.
     Ou lancez le workflow une première fois : l'échec affiche le `subject claim` exact.
3. Donnez à l'identité le rôle `Reader` sur son resource group.
4. Exposez en output `client_id`, `tenant_id` et `subscription_id`, puis `apply`.
5. Dans le dépôt GitHub, créez ces valeurs comme **variables** (Settings, Secrets and variables, Actions, onglet Variables) :
   `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `RESOURCE_GROUP`. Ce ne sont pas des secrets.
6. Copiez `jour2/bonus/azure-oidc.yml` dans `.github/workflows/` de votre dépôt et lancez-le (onglet Actions, Run workflow).

### Questions

- `az group list` dans le pipeline : combien de resource groups voit l'identité ? Pourquoi ?
- Que se passe-t-il si vous lancez le workflow depuis une autre branche que `main` ?

Détruisez le tout à la fin : `terraform destroy`.
