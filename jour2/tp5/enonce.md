# TP5 : mon cluster AKS

**Objectif** : créer un cluster AKS à un nœud, s'y connecter, puis le détruire. **Durée** : 50 minutes.

## Étapes

1. Dans un nouveau dossier, créez un resource group `rg-<prénom>-aks`, puis `aks.tf` :
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

## Questions

- Dans quel resource group Azure a-t-il placé les VM des nœuds ?
- Le passage à 2 nœuds recrée-t-il le cluster ?

## Pour aller plus loin

Ajoutez un pool `user` avec `azurerm_kubernetes_cluster_node_pool` (modèle dans `jour2/tp5/node-pool.tf.bonus`). Il double vos vCPU : détruisez-le vite.
