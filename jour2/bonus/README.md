# Bonus : un pipeline sans secret (OIDC)

**Objectif** : laisser GitHub Actions se connecter à Azure sans aucun secret, grâce à la fédération d'identité. **Durée** : 30 minutes.
Il réunit le TP3 (identité managée) et le TP4 (pipeline). Il vous faut un dépôt GitHub à vous.

## Étapes

1. Dans un nouveau dossier, créez un resource group `rg-<prénom>-oidc` et une identité managée `id-<prénom>-github`.
2. Ajoutez deux `azurerm_federated_identity_credential` sur cette identité (`user_assigned_identity_id`) :
   - `issuer = "https://token.actions.githubusercontent.com"`, `audience = ["api://AzureADTokenExchange"]` ;
   - `subject` : `<début>:ref:refs/heads/main`, puis `<début>:pull_request`.
     GitHub met dans `<début>` les identifiants numériques du propriétaire et du dépôt : `repo:<propriétaire>@<id>/<dépôt>@<id>`.
     Pour les connaître : `curl -s https://api.github.com/repos/<propriétaire>/<dépôt>`, champs `owner.id` et `id`.
     Ou lancez le workflow une première fois : l'échec affiche le `subject claim` exact.
3. Donnez à l'identité le rôle `Reader` sur son resource group.
4. Exposez en output `client_id`, `tenant_id` et `subscription_id`, puis `apply`.
5. Dans le dépôt GitHub, créez ces valeurs comme **variables** (Settings, Secrets and variables, Actions, onglet Variables) :
   `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `RESOURCE_GROUP`. Ce ne sont pas des secrets.
6. Copiez `jour2/bonus/azure-oidc.yml` dans `.github/workflows/` de votre dépôt et lancez-le (onglet Actions, Run workflow).

## Questions

- `az group list` dans le pipeline : combien de resource groups voit l'identité ? Pourquoi ?
- Que se passe-t-il si vous lancez le workflow depuis une autre branche que `main` ?

Détruisez le tout à la fin : `terraform destroy`.
