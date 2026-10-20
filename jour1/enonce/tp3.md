# TP3 : VNet et deux sous-réseaux

**Objectif** : construire le socle réseau du fil rouge. **Durée** : 40 minutes.

## Étapes

1. Ajoutez une variable `address_space` (liste, défaut `["10.0.0.0/16"]`).
2. Créez un `azurerm_virtual_network` nommé `vnet-${local.name_prefix}`.
3. Créez deux `azurerm_subnet` : `snet-app` (`10.0.1.0/24`) et `snet-data` (`10.0.2.0/24`).
4. Référencez le resource group et le VNet (`azurerm_resource_group.main.name`) au lieu de recopier leurs noms.
5. Exposez en outputs l'identifiant du VNet et ceux des deux sous-réseaux.
6. Lancez `plan`, observez l'ordre de création, puis `apply`.

## Questions

- Dans quel ordre Terraform crée-t-il les ressources ? Qui le décide ?
- Combien coûtent un VNet et ses sous-réseaux ?

## Pour aller plus loin

Ajoutez un troisième sous-réseau. Quel CIDR choisissez-vous, et pourquoi ?
