# Jour 3 : solutions

| Dossier | Correspond à |
|---|---|
| `tp1/` | `socle/` : réseau, identité et cluster ; `app/` : le provider et le namespace |
| `tp2/` | `jour3/app` complet, module avec le Service `LoadBalancer` et l'output `url` |
| `tp3/` | `jour3/socle` modifié : tags, labels, autoscaler (et `tag = "v2"` dans `jour3/app/main.tf`) |
| `bonus/` | `jour3/socle` du TP3, monté en 1.36 : canal `patch`, `max_surge` |

## TP1

- L'identité du cluster est créée avant lui (attribuée par l'utilisateur) pour recevoir `Network Contributor` sur le sous-réseau **avant** la création : AKS en a besoin dès sa naissance. Au TP5 d'hier, AKS créait son propre VNet, une identité attribuée par le système suffisait.
- `depends_on` sur l'attribution de rôle : rien dans le cluster ne la référence, sans lui Terraform pourrait les créer en parallèle.
- Un mauvais contexte déploie dans le cluster d'un autre : c'est pour cela qu'il est fixé dans le provider, pas laissé au contexte courant.
- Un module hérite des providers de la racine. Le déclarer dans le module empêcherait de le réutiliser avec un autre cluster.
- `state list` : dans `socle/`, les 6 ressources Azure ; dans `app/`, `kubernetes_namespace_v1.app`.

## TP2

- Le disque Azure (`ReadWriteOnce`) ne se monte que sur un nœud à la fois : un réplica, et `strategy = Recreate` pour libérer le disque avant de recréer le pod.
- Le Service crée une IP publique et une règle sur le load balancer `kubernetes`, dans le resource group des nœuds `MC_rg-<prénom>-j3_aks-<prénom>_swedencentral`.
- Pour aller plus loin : l'output `app_dns_url` affiche `http://tf-<prénom>.swedencentral.cloudapp.azure.com`.

## TP3

- Tags et labels : à vérifier en répétition. `temporary_name_for_rotation` permet à Terraform de faire tourner le pool si un changement l'exige.
- `tag = "v2"` : `3 to change`. Frontend et service A en rolling update (la page répond pendant l'apply, le bandeau passe au vert), service B en `Recreate` : son disque ne se monte que sur un nœud à la fois (courte coupure, le compteur survit).

## Bonus : montée de version

- Pendant la mise à jour : un nœud de surge (`max_surge`) est ajouté, les pods y sont déplacés, puis l'ancien nœud est supprimé. Avec un seul réplica du service B, son pod redémarre : courte coupure du compteur.
- `orchestrator_version = var.kubernetes_version` fait suivre les nœuds : sans lui, seul le plan de contrôle passe en 1.36.
- `patch` : les correctifs (1.36.x) sont appliqués automatiquement, pas les mineures.
