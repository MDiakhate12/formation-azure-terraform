# TP4 : NSG et règles avec for_each

**Objectif** : filtrer le trafic avec un NSG piloté par une variable. **Durée** : 30 minutes.

## Étapes

1. Déclarez une variable `nsg_rules` : une map d'objets `{ priority, port, access }`, avec par défaut :
   - `allow-https` : priorité 100, port `443`, `Allow` ;
   - `deny-ssh` : priorité 200, port `22`, `Deny`.
2. Créez un `azurerm_network_security_group` pour `snet-app`.
3. Créez ses règles avec **une seule** ressource `azurerm_network_security_rule` et `for_each`.
4. Associez le NSG à `snet-app` avec `azurerm_subnet_network_security_group_association`.
5. Ajoutez une variable booléenne `enable_data_nsg` (défaut `false`) : un second NSG, associé à `snet-data`, n'est créé que si elle vaut `true` (`count`).
6. Comparez `plan` sans, puis avec `-var="enable_data_nsg=true"`.

## Questions

- Comment s'appelle chaque règle dans le state (`terraform state list`) ?
- Comment référencer le NSG data, alors qu'il peut ne pas exister ?

## Pour aller plus loin

Ajoutez `lifecycle { prevent_destroy = true }` sur le NSG de `snet-app`, puis lancez `terraform destroy`.
