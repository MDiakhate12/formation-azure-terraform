# TP2 : importer et déplacer

**Objectif** : faire adopter une ressource existante par Terraform, puis la renommer sans la recréer. **Durée** : 30 minutes.

## Étapes

1. Créez un resource group à la main :
   `az group create -n rg-<prénom>-manuel -l swedencentral`
2. Dans un nouveau dossier, écrivez :
   - un bloc `resource "azurerm_resource_group" "legacy"` qui décrit ce resource group ;
   - un bloc `import` vers `azurerm_resource_group.legacy`. Son `id` est de la forme
     `/subscriptions/<id>/resourceGroups/rg-<prénom>-manuel` : construisez-le avec `data.azurerm_subscription.current.id`.
3. `plan` : le plan doit annoncer **1 to import**, 0 to add. Puis `apply`.
4. Renommez la ressource en `azurerm_resource_group.manuel`, ajoutez un bloc `moved` et mettez à jour le `to` du bloc `import`.
   Le plan doit annoncer 0 to add, 0 to destroy.
5. Lisez le resource group partagé `rg-formation-partage` avec un `data` et affichez son id et sa région en output.

## Questions

- Que se passerait-il au `plan` de l'étape 4 sans le bloc `moved` ?
- Pourquoi `apply` ne détruira jamais `rg-formation-partage` ?

## Pour aller plus loin

Supprimez le bloc `resource` et laissez Terraform l'écrire : `terraform plan -generate-config-out=generated.tf`.
