# TP3 : une identité managée avec un rôle

**Objectif** : créer une identité sans mot de passe et lui donner un accès minimal. **Durée** : 40 minutes.

## Étapes

1. Dans un nouveau dossier, créez un resource group `rg-<prénom>-identite`.
2. Créez une `azurerm_user_assigned_identity` nommée `id-<prénom>-app`.
3. Attribuez-lui le rôle `Reader` **sur ce resource group seulement** (`azurerm_role_assignment`, `scope` = id du resource group).
4. Affichez son `principal_id` en output, puis `apply`.
5. Vérifiez : `az role assignment list --scope <id du resource group> -o table`.
6. Retirez le bloc `azurerm_role_assignment` du code : que dit le plan ? Appliquez, puis vérifiez à nouveau.

Vous ne pouvez attribuer que les rôles Reader, Network Contributor et AcrPull : c'est voulu.
Essayez `Contributor` à la place de `Reader` et lisez l'erreur.

## Questions

- Où est le mot de passe de cette identité ?
- Quelle différence entre `principal_id` et `client_id` ?

## Pour aller plus loin

Affichez votre propre `object_id` avec `data "azurerm_client_config" "current"`.
