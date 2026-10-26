# TP5 : mon cluster AKS

[Sommaire du jour 2](../enonce.md) · [Se connecter à Azure](../enonce.md#avant-de-commencer)

**Objectif** : créer un cluster Kubernetes managé à un nœud, s'y connecter, puis le détruire. **Durée** : 50 minutes.
**Dossier de travail** : `jour2/tp5/` (le fichier `versions.tf` y est déjà)

Ce TP est un **cahier des charges** : pas de code à compléter. Vous écrivez tout à partir des specs ci-dessous et de la documentation.
Lisez la doc, lisez les messages d'erreur : c'est le travail réel avec Terraform.

## Où on en est, où on va

AKS est le Kubernetes managé d'Azure : Azure gère le plan de contrôle, vous gérez les nœuds (des VM) et ce qui tourne dessus.
À la fin de ce TP, vous aurez créé un cluster `aks-<prénom>`, vous y serez connecté avec `kubectl`, et vous l'aurez détruit.

> **Règle du temps** : la création du cluster prend 5 à 10 minutes. Lancez votre premier `apply` **au plus tard 20 minutes** après le début du TP, quitte à compléter le reste pendant l'attente.

## Les specs

### Variables

| Nom | Type | Défaut |
|---|---|---|
| `prenom` | `string` | aucun (reprenez celle du TP1, avec sa validation) |
| `location` | `string` | `swedencentral` |
| `node_count` | `number` | `1` |

Les valeurs dans `dev.tfvars` : vous pouvez repartir de `../tp1/variables.tf` et `../tp1/dev.tfvars`.

### Ressources

| Ressource | Specs |
|---|---|
| Resource group | Nom `rg-<prénom>-aks`, région `var.location` |
| Cluster `azurerm_kubernetes_cluster` | Nom `aks-<prénom>`, `dns_prefix` identique, dans le resource group ci-dessus |
| Pool de nœuds par défaut | Le bloc `default_node_pool`, dans le cluster : `name = "system"`, `vm_size` = `Standard_D2as_v6` (la seule autorisée), `node_count` = votre variable. **N'écrivez pas** d'argument `zones` |
| Identité du cluster | Le bloc `identity`, dans le cluster, avec `type = "SystemAssigned"` : une identité managée attribuée par le système, créée et supprimée avec le cluster |

### Lecture du registre partagé

Un data source **lit** une ressource qui existe déjà, sans jamais la créer ni la détruire. Sa forme :

```hcl
data "<type>" "<nom choisi>" {
  # les arguments qui identifient la ressource à lire
}
```

Il se référence ensuite avec le préfixe `data.` : `data.<type>.<nom choisi>.<attribut>`.

À vous : le type `azurerm_container_registry`. La section **Argument Reference** de [sa documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/container_registry) donne les deux arguments obligatoires : le nom du registre (`acrformationtf`) et son resource group (`rg-formation-partage`). La section **Attributes Reference** liste ce que vous pouvez lire, dont `login_server`.

### Sorties

Chaque output a la forme `output "<nom>" { value = ... }`. Les valeurs viennent toutes de **références**, jamais de texte écrit en dur.

| Output | Valeur | Indice |
|---|---|---|
| `kubernetes_version` | La version de Kubernetes du cluster | Un attribut du cluster qui porte ce nom : voir **Attributes Reference** de `azurerm_kubernetes_cluster` |
| `registry_login_server` | L'adresse du registre | L'attribut `login_server` de votre data source, avec le préfixe `data.` |

### Se connecter au cluster

`kubectl` ne sait pas seul à quel cluster parler. La commande `az aks get-credentials` va chercher dans Azure l'adresse du cluster et ses accès, et les écrit dans `~/.kube/config`.
Cette étape est hors Terraform : on demande seulement à Terraform d'**afficher** la commande, construite avec vos références. Sur une subscription partagée par tout le groupe, elle vise ainsi forcément **votre** cluster.

**À compléter** dans `outputs.tf` :

```hcl
output "get_credentials" {
  value = "az aks get-credentials --resource-group ${...} --name ${...}"   # À COMPLÉTER : le nom du resource group, puis celui du cluster (références)
}
```

Une fois le cluster créé, **à lancer** :

```bash
# Affiche la commande, prête à copier-coller
terraform output -raw get_credentials
# Collez et lancez la commande affichée, puis :
kubectl get nodes
```

> **Explication.** On n'écrit pas le kubeconfig avec Terraform : il contient des secrets, qui finiraient en clair dans le state. La commande affichée ne contient aucun secret : c'est `az`, avec votre session, qui va chercher les accès.

## Les critères de réussite

1. `terraform plan` annonce `2 to add` avant le premier `apply`.
2. Les trois outputs s'affichent, dont `acrformationtf.azurecr.io` et la commande `az aks get-credentials` de votre cluster.
3. Après avoir lancé la commande de `get_credentials` : `kubectl get nodes` affiche **un** nœud `Ready`, et `kubectl get pods -A` les pods système.
4. `terraform plan -var-file=dev.tfvars -var="node_count=2"` montre une modification **en place** (`~`) : lisez-la, **n'appliquez pas**.
5. Dans le portail : retrouvez le resource group `MC_...` créé par AKS, qui contient les VM des nœuds.
6. `terraform destroy -var-file=dev.tfvars` : le cluster coûte à l'heure, même sans rien faire.

## Documentation

- [`azurerm_kubernetes_cluster`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) : lisez les arguments **Required** et la section `default_node_pool`
- [Data source `azurerm_container_registry`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/container_registry)
- [`az aks get-credentials`](https://learn.microsoft.com/cli/azure/aks#az-aks-get-credentials)

## Coups de pouce (à n'ouvrir qu'en cas de blocage)

<details>
<summary>« Insufficient node_provisioning_profile blocks »</summary>

Le provider azurerm 5 exige un bloc que la plupart des exemples sur Internet n'ont pas encore. Lisez la section `node_provisioning_profile` de la documentation : la valeur `Manual` signifie « c'est moi qui déclare les pools de nœuds ».

</details>


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
