# TP3 : exploiter le cluster

**Objectif** : modifier le cluster en place, avec des labels, l'autoscaler et une montée de version. **Durée** : 40 minutes.
Toutes les modifications se font dans `jour3/socle/aks.tf`. **Lisez chaque plan avant de répondre `yes`.**

## Étapes

1. Ajoutez au `default_node_pool` des `tags` (`owner = var.prenom`) et des `node_labels` (`role = "system"`).
   Le plan est-il `~` (en place) ou `-/+` (remplacement) ?
2. Activez l'autoscaler : `auto_scaling_enabled = true`, `min_count = 1`, `max_count = 2`, et retirez `node_count`.
3. Lancez la montée de version **tôt** (15 à 25 minutes) : `kubernetes_version = "1.36"`, puis `apply`.
4. Pendant ce temps, dans un autre terminal : `kubectl get nodes -w`, et actualisez l'URL de votre application.
5. Combien de nœuds voyez-vous pendant la mise à jour ? Votre application a-t-elle été coupée ?

## Questions

- Pourquoi un nœud supplémentaire apparaît-il pendant la mise à jour ?
- Que fait `automatic_upgrade_channel = "patch"` ?

## Pour aller plus loin

Ajoutez un pool `apps` avec le label `role = "apps"` (modèle dans `jour3/enonce/node-pool.tf.bonus`),
puis passez `node_selector = { role = "apps" }` au module : sur quel nœud vont les pods ? Détruisez le pool ensuite (quota).
