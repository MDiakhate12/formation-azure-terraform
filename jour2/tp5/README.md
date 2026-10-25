# TP5 : mon cluster AKS

[Sommaire du jour 2](../enonce.md) · [Se connecter à Azure](../enonce.md#avant-de-commencer)

**Objectif** : créer un cluster Kubernetes managé à un nœud, s'y connecter, puis le détruire. **Durée** : 50 minutes.
**Dossier de travail** : `jour2/tp5/` (le fichier `versions.tf` y est déjà)

## Où on en est, où on va

AKS est le Kubernetes managé d'Azure : Azure gère le plan de contrôle, vous gérez les nœuds (des VM) et ce qui tourne dessus.
À la fin de ce TP, vous aurez créé un cluster `aks-<prénom>`, vous y serez connecté avec `kubectl`, et vous l'aurez détruit. Demain, le code du cluster est fourni : il recréera le même.

## Étape 1 : se placer dans le dossier, déclarer les variables

**À lancer** :

```bash
# Depuis la racine du dépôt cloné
cd jour2/tp5
cp ../tp1/variables.tf ../tp1/dev.tfvars .
```

**À écrire** à la fin de `variables.tf` : une variable `node_count`, de type `number`, avec `1` par défaut.

## Étape 2 : le cluster

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

> **Explication.**
> - `default_node_pool` : le groupe de nœuds système. Pas d'argument `zones` : la création ne dépend pas de la capacité d'une zone précise.
> - `identity { type = "SystemAssigned" }` : le cluster reçoit sa propre identité managée, pour créer ses disques et ses IP.
> - `node_provisioning_profile { mode = "Manual" }` : obligatoire avec azurerm 5. `Manual` : c'est vous qui déclarez les pools de nœuds.

## Étape 3 : lancer la création tout de suite

La création prend 5 à 10 minutes : lancez-la maintenant, vous écrirez la suite pendant l'attente.

**À lancer** :

```bash
terraform init
# Lisez le plan, puis tapez yes : la création démarre
terraform apply -var-file=dev.tfvars
```

**Vérifier** : le plan annonce `2 to add`. Laissez ce terminal tourner et passez à l'étape 4.

## Étape 4 : pendant l'attente, lire le registre et préparer les sorties

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

## Étape 5 : se connecter au cluster

**À lancer** :

```bash
# Affiche la commande qui écrit les accès du cluster dans ~/.kube/config
terraform output -raw get_credentials
# Copiez-collez la commande affichée, puis :
kubectl get nodes
kubectl get pods -A
```

**Vérifier** : `kubectl get nodes` affiche un nœud `Ready`, et `get pods -A` les pods système de Kubernetes.

## Étape 6 : lire un changement sans l'appliquer

**À lancer** :

```bash
# Plan avec deux nœuds au lieu d'un : on lit, on n'applique pas
terraform plan -var-file=dev.tfvars -var="node_count=2"
```

**Vérifier** : le plan affiche `~` (modification en place) : le cluster ne serait pas recréé.

## Étape 7 : retrouver le cluster dans le portail

1. Ouvrez `rg-<prénom>-aks`, puis `aks-<prénom>` : la vue d'ensemble affiche la version de Kubernetes et l'état `Succeeded`.
2. Menu **Settings > Node pools** (Paramètres > Pools de nœuds) : le pool `system`, 1 nœud, `Standard_D2as_v6`.
3. Cherchez le resource group `MC_rg-<prénom>-aks_aks-<prénom>_swedencentral` : AKS l'a créé seul, il contient les VM des nœuds.

## Étape 8 : détruire le cluster

Un cluster coûte à l'heure, même sans rien faire.

**À lancer** :

```bash
# Supprime le cluster et son resource group (tapez yes) : quelques minutes
terraform destroy -var-file=dev.tfvars
```

## Documentation

- [`azurerm_kubernetes_cluster`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)
- [Data source `azurerm_container_registry`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/container_registry)

## Questions

- Dans quel resource group Azure a-t-il placé les VM des nœuds ?
- Le passage à 2 nœuds recrée-t-il le cluster ?

## Pour aller plus loin

Ajoutez un pool `user`, **avant** le `destroy`.

**À lancer** :

```bash
# Le modèle fourni devient un fichier Terraform actif
mv node-pool.tf.bonus node-pool.tf
terraform apply -var-file=dev.tfvars
```

Il double vos vCPU : détruisez-le dès que vous l'avez vu (`terraform destroy -var-file=dev.tfvars`).

---

Précédent : [TP4 : premier pipeline](../tp4/README.md) · Suivant : [Bonus : un pipeline sans secret (OIDC)](../bonus/README.md) · [Sommaire du jour 2](../enonce.md)
