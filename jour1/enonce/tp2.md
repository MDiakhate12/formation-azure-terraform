# TP2 : variabiliser et nommer

**Objectif** : remplacer les valeurs en dur par des variables, des locals et des outputs. **Durée** : 30 minutes.

## Étapes

1. Créez `variables.tf` avec trois variables :
   - `prenom` (sans valeur par défaut) ;
   - `location` (défaut `westeurope`) ;
   - `environment` (défaut `dev`), avec une `validation` qui n'accepte que `dev` ou `prod`.
2. Créez un local `name_prefix` qui vaut `<prénom>-<environment>` et nommez le resource group `rg-${local.name_prefix}`.
3. Ajoutez un output `resource_group_id`.
4. Créez `dev.tfvars` avec votre prénom, puis lancez `terraform plan -var-file=dev.tfvars`.
5. Relancez avec en plus `-var="environment=prod"` : quelle valeur gagne ?

## Questions

- Le plan veut remplacer le resource group du TP1 (`-/+`). Pourquoi ?
- Que se passe-t-il si vous oubliez `-var-file` ?

## Pour aller plus loin

Faites échouer la validation volontairement avec `environment=test` et lisez le message.
