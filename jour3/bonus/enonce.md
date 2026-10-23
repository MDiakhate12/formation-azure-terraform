# Bonus : déployer un chart Helm

**Objectif** : installer une application packagée par Helm, avec Terraform. **Durée** : 20 minutes.

## Étapes

1. Dans un nouveau dossier, déclarez le provider `hashicorp/helm` en `~> 3.0`.
   En version 3, la connexion au cluster est un **attribut** : `kubernetes = { config_path = "...", config_context = "..." }`.
2. Créez un `helm_release` :
   - `repository = "https://stefanprodan.github.io/podinfo"`, `chart = "podinfo"`, une `version` fixée ;
   - `namespace = "bonus"`, `create_namespace = true` ;
   - `set` : `replicaCount = 2` et `ui.message` avec votre prénom.
3. `apply`, puis `kubectl get all -n bonus`.
4. `kubectl port-forward -n bonus svc/podinfo 9898:9898` et ouvrez `http://localhost:9898`.

## Questions

- Combien d'objets Kubernetes le chart a-t-il créés ? Combien Terraform en voit-il dans son state ?
- Quand préférer Helm aux ressources `kubernetes_*` ?

Détruisez à la fin : `terraform destroy`.
