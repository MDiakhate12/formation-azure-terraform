# TP4 : pannes volontaires

**Objectif** : diagnostiquer et corriger trois pannes dans une application préparée. **Durée** : 30 minutes.
Le state de `jour3/pannes` est dans un stockage partagé : chacun a sa propre clé.

## Mise en place

```bash
cd pannes
terraform init -backend-config="key=<prénom>.tfstate"
terraform apply -var-file=dev.tfvars
```

## Les pannes

1. **Un pod reste en `ImagePullBackOff`.** Trouvez la cause avec `kubectl describe pod -n pannes <pod>` (section Events), corrigez le code, `apply`.
2. **Le Service `service-a` n'a pas d'endpoints.** Comparez `kubectl get endpoints -n pannes service-a`, le `selector` du Service et les labels des pods (`kubectl get pods -n pannes --show-labels`).
3. **Un apply est verrouillé.** Lancez `./casser-verrou.sh` (sous Windows : `terraform apply`, puis fermez brutalement la fenêtre), puis `terraform plan -var-file=dev.tfvars`.
   Lisez le message et levez le verrou proprement.

## Puis

Relancez `plan` avec `TF_LOG=DEBUG` et `TF_LOG_PATH=terraform.log`, et repérez un appel à l'API Kubernetes ou Azure dans le fichier.

## Questions

- Pour chaque panne : quelle commande vous a donné la cause ?
- Quand `force-unlock` est-il dangereux ?

## Pour aller plus loin

Supprimez le Service `frontend` avec `kubectl delete svc -n pannes frontend`, puis `terraform plan -refresh-only` : que propose Terraform ?
