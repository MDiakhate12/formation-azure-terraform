# TP1 : un state distant

**Objectif** : créer le stockage du state avec Terraform, puis y migrer le state. **Durée** : 30 minutes.

## Étapes

1. Dans un nouveau dossier, déclarez les variables `prenom` et `location`, puis créez :
   - un resource group `rg-<prénom>-tfstate` ;
   - un `azurerm_storage_account` nommé `st<prénom>tfstate` (Standard, LRS, `shared_access_key_enabled = true`) ;
   - un `azurerm_storage_container` privé `tfstate`, rattaché au compte par `storage_account_id`.
2. `terraform init`, puis `apply`. Le state est encore local : repérez `terraform.tfstate`.
3. Ajoutez `backend.tf` avec un bloc `backend "azurerm"` (`resource_group_name`, `storage_account_name`, `container_name`, `key = "jour2.tfstate"`). Les valeurs sont écrites en dur : un backend n'accepte pas de variables.
4. `terraform init -migrate-state`, répondez `yes`.
5. Vérifiez le blob :
   `az storage blob list --account-name st<prénom>tfstate -c tfstate --auth-mode key -o table`
6. Provoquez un verrou : lancez `terraform apply` dans un terminal et, sans répondre, `terraform plan` dans un second.

Nom déjà pris (`StorageAccountAlreadyTaken`) ? Le nom est unique dans tout Azure : ajoutez deux chiffres.

## Questions

- Où se trouve maintenant le fichier `terraform.tfstate` local ? Que contient-il ?
- Quel message affiche le second terminal pendant le verrou ?

## Pour aller plus loin

`terraform state list`, puis `terraform state show azurerm_storage_account.state`.
