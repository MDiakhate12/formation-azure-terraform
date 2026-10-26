# TP5 : mon cluster AKS

[Sommaire du jour 2](../enonce.md) · [Se connecter à Azure](../enonce.md#avant-de-commencer)

**Objectif** : créer un cluster Kubernetes managé à un nœud, s'y connecter, puis le détruire. **Durée** : 50 minutes.
**Dossier de travail** : `jour2/tp5/` (le fichier `versions.tf` y est déjà)

Ce TP est un **cahier des charges** : vous écrivez le code à partir des specs et de la documentation. Chaque partie dit dans quel fichier écrire, puis quand lancer `apply`.
Bloqué, ou la syntaxe vous échappe ? Chaque partie a un bloc **Syntaxe** à déplier.

## Où on en est, où on va

AKS est le Kubernetes managé d'Azure : Azure gère le plan de contrôle, vous gérez les nœuds (des VM) et ce qui tourne dessus.
À la fin de ce TP, vous aurez créé un cluster `aks-<prénom>`, vous y serez connecté avec `kubectl`, et vous l'aurez détruit.

> **Règle du temps** : la création du cluster prend 5 à 10 minutes. Lancez l'`apply` de la **partie 2** au plus tard 20 minutes après le début du TP. Vous écrirez les parties 3 et 4 pendant l'attente.

## Partie 1 : les variables

**Fichiers** : `variables.tf` et `dev.tfvars`. Repartez de ceux du TP1 : `cp ../tp1/variables.tf ../tp1/dev.tfvars .`

| Variable | Type | Défaut |
|---|---|---|
| `prenom` | `string` | aucun, avec la validation du TP1 (déjà copiée) |
| `location` | `string` | `swedencentral` (déjà copiée) |
| `node_count` | `number` | `1` : **à ajouter** |

Documentation : [les variables](https://developer.hashicorp.com/terraform/language/values/variables).

<details>
<summary>Syntaxe : une variable</summary>

```hcl
variable "<nom>" {
  type        = <type>
  description = "<à quoi elle sert>"
  default     = <valeur>
}
```

</details>

**À lancer** : `terraform init` (nouveau dossier, donc nouvel `init`).

## Partie 2 : le cluster, et son apply tout de suite

**Fichier** : `main.tf`.

| Ressource | Specs |
|---|---|
| Resource group `azurerm_resource_group` | Nom `rg-<prénom>-aks`, région `var.location` |
| Cluster `azurerm_kubernetes_cluster` | Nom `aks-<prénom>`, `dns_prefix` identique, dans le resource group ci-dessus |
| Pool de nœuds par défaut | Le bloc `default_node_pool`, dans le cluster : `name = "system"`, `vm_size` = `Standard_D2as_v6` (la seule autorisée), `node_count` = votre variable. **N'écrivez pas** d'argument `zones` |
| Identité du cluster | Le bloc `identity`, dans le cluster, avec `type = "SystemAssigned"` : une identité managée attribuée par le système, créée et supprimée avec le cluster |
| Provisionnement des nœuds | Le bloc `node_provisioning_profile`, avec `mode = "Manual"` : obligatoire avec azurerm 5 |

Documentation : [`azurerm_kubernetes_cluster`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster). Lisez les arguments **Required**, puis les sections `default_node_pool`, `identity` et `node_provisioning_profile`.

<details>
<summary>Syntaxe : le cluster et ses blocs</summary>

```hcl
resource "azurerm_kubernetes_cluster" "main" {
  name                = "<nom du cluster>"
  location            = <référence à la région du resource group>
  resource_group_name = <référence au nom du resource group>
  dns_prefix          = "<préfixe DNS>"

  default_node_pool {
    name       = "<nom du pool>"
    vm_size    = "<taille des nœuds>"
    node_count = <nombre de nœuds>
  }

  identity {
    type = "<type d'identité>"
  }

  node_provisioning_profile {
    mode = "<mode>"
  }
}
```

Erreur `Insufficient node_provisioning_profile blocks` ? Le bloc `node_provisioning_profile` manque : la plupart des exemples sur Internet sont antérieurs à azurerm 5 et ne l'ont pas.

</details>

**À lancer** dès que `terraform validate` passe :

```bash
# Lisez le plan (2 to add), tapez yes : la création démarre, 5 à 10 minutes
terraform apply -var-file=dev.tfvars
```

**Laissez ce terminal tourner** et passez à la partie 3. Le state est verrouillé pendant l'`apply` : n'en lancez pas un second avant la fin du premier.

## Partie 3 : pendant l'attente, lire le registre partagé

**Fichier** : `registry.tf`.

Un data source **lit** une ressource qui existe déjà, sans jamais la créer ni la détruire. Ici, le registre `acrformationtf`, dans le resource group `rg-formation-partage`.

Documentation : [data source `azurerm_container_registry`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/container_registry). La section **Argument Reference** donne les deux arguments obligatoires, la section **Attributes Reference** ce que vous pouvez lire, dont `login_server`.

<details>
<summary>Syntaxe : un data source</summary>

```hcl
data "<type>" "<nom choisi>" {
  name                = "<nom de la ressource à lire>"
  resource_group_name = "<son resource group>"
}
```

Il se référence avec le préfixe `data.` : `data.<type>.<nom choisi>.<attribut>`.

</details>

## Partie 4 : pendant l'attente, les sorties

**Fichier** : `outputs.tf`.

| Output | Valeur | Indice |
|---|---|---|
| `kubernetes_version` | La version de Kubernetes du cluster | Un attribut du cluster qui porte ce nom : voir **Attributes Reference** de `azurerm_kubernetes_cluster` |
| `registry_login_server` | L'adresse du registre | L'attribut `login_server` de votre data source, avec le préfixe `data.` |

Documentation : [les outputs](https://developer.hashicorp.com/terraform/language/values/outputs).

**À compléter**, dans le même fichier, une troisième sortie. Elle n'est pas du Terraform au sens strict : `kubectl` ne sait pas seul à quel cluster parler, et la commande `az aks get-credentials` va chercher son adresse et ses accès pour les écrire dans `~/.kube/config`. On demande seulement à Terraform d'**afficher** cette commande, construite avec vos références : sur une subscription partagée, elle vise ainsi forcément **votre** cluster.

```hcl
output "get_credentials" {
  value = "az aks get-credentials --resource-group ${...} --name ${...}"   # À COMPLÉTER : le nom du resource group, puis celui du cluster (références)
}
```

> **Explication.** On n'écrit pas le kubeconfig avec Terraform : il contient des secrets, qui finiraient en clair dans le state. La commande affichée n'en contient aucun : c'est `az`, avec votre session, qui va chercher les accès.

<details>
<summary>Syntaxe : un output</summary>

```hcl
output "<nom>" {
  value = <référence ou expression>
}
```

Une référence dans une chaîne : `"texte ${azurerm_resource_group.main.name} texte"`.

</details>

**À lancer** quand l'`apply` de la partie 2 est **terminé** :

```bash
# Ajoute la lecture du registre et les sorties : aucune ressource créée
terraform apply -var-file=dev.tfvars
```

**Vérifier** : `0 to add`, puis les trois outputs s'affichent, dont `acrformationtf.azurecr.io`.

## Partie 5 : se connecter au cluster

**À lancer** :

```bash
# Affiche la commande, prête à copier-coller
terraform output -raw get_credentials
# Collez et lancez la commande affichée, puis :
kubectl get nodes
kubectl get pods -A
```

**Vérifier** : `kubectl get nodes` affiche **un** nœud `Ready`, `get pods -A` les pods système de Kubernetes.

## Partie 6 : lire un changement sans l'appliquer

**À lancer** :

```bash
# Plan avec deux nœuds au lieu d'un : on lit, on n'applique pas
terraform plan -var-file=dev.tfvars -var="node_count=2"
```

**Vérifier** : le plan affiche `~` (modification en place) : le cluster ne serait pas recréé.

## Partie 7 : retrouver le cluster dans le portail

1. Ouvrez `rg-<prénom>-aks`, puis `aks-<prénom>` : la vue d'ensemble affiche la version de Kubernetes et l'état `Succeeded`.
2. Menu **Settings > Node pools** (Paramètres > Pools de nœuds) : le pool `system`, 1 nœud, `Standard_D2as_v6`.
3. Cherchez le resource group `MC_rg-<prénom>-aks_aks-<prénom>_swedencentral` : AKS l'a créé seul, il contient les VM des nœuds.

## Partie 8 : détruire le cluster

Un cluster coûte à l'heure, même sans rien faire. Faites d'abord le « Pour aller plus loin » si vous le souhaitez, puis :

```bash
# Supprime le cluster et son resource group (tapez yes) : quelques minutes
terraform destroy -var-file=dev.tfvars
```

## Questions

- Dans quel resource group Azure a-t-il placé les VM des nœuds ?
- Le passage à 2 nœuds recrée-t-il le cluster ?
- Quel argument de la documentation vous a demandé le plus de recherche ?

## Pour aller plus loin

Ajoutez un second pool de nœuds, **avant** le `destroy`.

### Le fichier fourni : `node-pool.tf.bonus`

Il décrit un pool nommé `user`, déjà écrit. Son extension `.bonus` le rend **invisible** pour Terraform, qui ne lit que les fichiers `.tf` du dossier : il ne compte pas tant que vous ne le renommez pas.

```hcl
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id   # rattaché à votre cluster
  vm_size               = "Standard_D2as_v6"
  node_count            = 1
}
```

> **Explication.**
> - Un cluster AKS a toujours un pool **système** (`default_node_pool`), qui fait tourner les composants de Kubernetes : DNS, réseau, supervision.
> - Les pools **utilisateur** accueillent vos applications. Les séparer protège le système : une application gourmande ne peut pas l'étouffer.
> - Un pool supplémentaire est une ressource à part, `azurerm_kubernetes_cluster_node_pool`, reliée au cluster par son id : on l'ajoute ou le retire sans toucher au cluster.

### À lancer

```bash
# Le modèle devient un fichier Terraform actif (PowerShell : Rename-Item node-pool.tf.bonus node-pool.tf)
mv node-pool.tf.bonus node-pool.tf
# Le plan annonce 1 to add : le cluster n'est pas modifié
terraform apply -var-file=dev.tfvars
kubectl get nodes
```

**Vérifier** : `kubectl get nodes` affiche **deux** nœuds, un par pool. Dans le portail, **Settings > Node pools** liste `system` et `user`.

### Retirer le pool

Il **double vos vCPU** sur un quota partagé par tout le groupe. Retirez-le dès que vous l'avez vu, sans détruire le cluster :

```bash
# Redevient invisible pour Terraform : le plan annonce 1 to destroy, le pool seulement
mv node-pool.tf node-pool.tf.bonus
terraform apply -var-file=dev.tfvars
```

Ou passez directement au `terraform destroy` de la fin du TP, qui supprime tout.

---

Précédent : [TP4 : premier pipeline](../tp4/README.md) · Suivant : [Bonus : un pipeline sans secret (OIDC)](../bonus/README.md) · [Sommaire du jour 2](../enonce.md)
