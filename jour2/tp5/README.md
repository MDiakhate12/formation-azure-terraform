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
| Pool de nœuds par défaut | Nom `system`, taille `Standard_D2as_v6` (la seule autorisée), nombre de nœuds `var.node_count`, **aucune zone** |
| Identité du cluster | Identité managée attribuée par le système |

### Lecture du registre partagé

Un data source qui lit le registre `acrformationtf`, dans le resource group `rg-formation-partage`. Il ne crée rien.

### Sorties

| Output | Valeur |
|---|---|
| `get_credentials` | La commande `az aks get-credentials` complète pour **votre** cluster, construite à partir des références |
| `kubernetes_version` | La version de Kubernetes du cluster |
| `registry_login_server` | L'adresse du registre lu par le data source |

## Les critères de réussite

1. `terraform plan` annonce `2 to add` avant le premier `apply`.
2. Les trois outputs s'affichent, dont `acrformationtf.azurecr.io`.
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

<details>
<summary>La commande de connexion au cluster</summary>

`az aks get-credentials --resource-group <resource group> --name <cluster>` : remplacez les deux valeurs par des **références** Terraform dans une interpolation `"${...}"`, puis `terraform output -raw get_credentials` pour l'afficher et la copier-coller.

</details>

## Questions

- Dans quel resource group Azure a-t-il placé les VM des nœuds ?
- Le passage à 2 nœuds recrée-t-il le cluster ?
- Quel argument de la documentation vous a demandé le plus de recherche ?

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
