# TP1 : mon premier resource group

**Objectif** : déployer, puis détruire, un resource group avec Terraform. **Durée** : 30 minutes.

## Étapes

1. Connectez-vous et exportez `ARM_SUBSCRIPTION_ID` (voir le [README](README.md)).
2. Dans votre dossier de travail, créez `main.tf` avec :
   - un bloc `terraform` qui exige Terraform `>= 1.15.0` et le provider `hashicorp/azurerm` en `~> 5.0` ;
   - un bloc `provider "azurerm"` avec `features {}` ;
   - un `azurerm_resource_group` nommé `rg-<prénom>-tf`, en `swedencentral`.
3. Enchaînez `terraform init`, `fmt`, `validate`, `plan`, puis `apply`.
4. Retrouvez votre resource group dans le portail Azure.
5. Lancez `terraform destroy`, puis `apply` à nouveau : la même infrastructure revient.

## Questions

- Qu'a créé `terraform init` dans votre dossier ?
- Dans le plan, que signifie le symbole `+` ?

## Pour aller plus loin

Ajoutez un tag `owner` au resource group et lisez le plan : quel symbole apparaît ?
