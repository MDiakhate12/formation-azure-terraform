# TP1 : brancher Terraform sur le cluster

**Objectif** : configurer le provider `kubernetes` et créer un premier objet dans le cluster. **Durée** : 30 minutes.

## Étapes

1. Vérifiez que le cluster répond : `kubectl get nodes`, puis `kubectl config current-context` (il doit afficher `aks-<prénom>`).
2. Dans `jour3/app`, créez `providers.tf` avec un provider `kubernetes` :
   - `config_path = "~/.kube/config"` ;
   - `config_context` : le contexte de votre cluster (`aks-<prénom>`).
3. Créez un namespace `app` avec `kubernetes_namespace_v1`.
4. `terraform init`, `apply -var-file=dev.tfvars`, puis `kubectl get ns`.
5. Lisez `modules/app` : quelles variables attend-il ? Lesquelles ont une valeur par défaut ?

## Questions

- Que se passe-t-il si `config_context` désigne le cluster d'un autre participant ?
- Pourquoi déclarer le provider à la racine et pas dans le module ?

## Pour aller plus loin

`terraform state list` : quelles ressources Terraform connaît-il dans le cluster ?
