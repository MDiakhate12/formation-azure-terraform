# TP5 : module réseau

**Objectif** : mutualiser le réseau dans un module appelé deux fois. **Durée** : 50 minutes.

## Étapes

1. Créez `modules/network/` avec `main.tf`, `variables.tf` et `outputs.tf`.
2. Déplacez-y le VNet, les sous-réseaux, le NSG, ses règles et l'association.
3. Variables d'entrée du module : `prefix`, `resource_group_name`, `location`, `address_space`, `subnets` (map nom vers CIDR) et `nsg_rules`.
   Le module doit créer ses sous-réseaux avec `for_each` sur `subnets`.
4. Outputs du module : `vnet_id` et `subnet_ids` (une map).
5. À la racine, gardez le resource group (renommez-le `rg-<prénom>-reseau`) et appelez le module deux fois :
   - `network_dev` : `prefix = "dev"`, `10.10.0.0/16`, sous-réseaux `10.10.1.0/24` et `10.10.2.0/24` ;
   - `network_prod` : `prefix = "prod"`, `10.20.0.0/16`, sous-réseaux `10.20.1.0/24` et `10.20.2.0/24`.
6. Relancez `terraform init` (obligatoire après l'ajout d'un module), puis `plan` : combien de ressources vont être créées ?
7. Exposez les outputs des deux appels, puis `apply`.

## Questions

- Pourquoi `init` est-il nécessaire après l'ajout d'un module ?
- Le plan veut détruire votre ancien réseau. Comment l'éviter ? (Réponse demain, avec le bloc `moved`.)

## Pour aller plus loin

Supprimez la variable `subnets` et calculez les CIDR dans le module avec `cidrsubnet(var.address_space[0], 8, n)`.
