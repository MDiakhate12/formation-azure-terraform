# Jour 1 : solutions

Chaque dossier est l'état attendu **à la fin** du TP. Pour repartir d'une solution :

```bash
cp -r solutions/tp3/. .        # depuis jour1/
# remplacer "prenom" dans dev.tfvars, puis :
terraform init
terraform plan -var-file=dev.tfvars
```

## TP1

- `init` crée `.terraform/` (le provider téléchargé) et `.terraform.lock.hcl` (sa version exacte, à versionner).
- `+` : création. Avec le tag `owner`, le plan affiche `~` : modification en place, sans recréation.

## TP2

- Le resource group passe de `rg-prenom-tf` à `rg-prenom-dev` : le nom ne peut pas changer sur Azure, donc Terraform détruit puis recrée (`-/+`).
- Sans `-var-file`, Terraform demande `prenom` (pas de valeur par défaut).
- Ordre de priorité : `-var` en ligne de commande l'emporte sur `-var-file`, qui l'emporte sur `default`.

## TP3

- Le resource group d'abord, puis le VNet, puis les sous-réseaux, en parallèle : Terraform déduit l'ordre des références.
- VNet et sous-réseaux sont gratuits.
- Troisième sous-réseau : `10.0.3.0/24` (libre dans le `/16`, ne chevauche pas les deux autres).

## TP4

- Plan, à la suite du TP3 : 4 ressources à ajouter (le NSG, ses 2 règles, l'association), 6 avec `enable_data_nsg=true`. Depuis un dossier vide : 8 (10).
- Dans le state : `azurerm_network_security_rule.app["allow-https"]` et `azurerm_network_security_rule.app["deny-ssh"]`.
- Le NSG data se référence par `azurerm_network_security_group.data[0].id`, uniquement là où `count` garantit qu'il existe.
- `for_each` plutôt que `count` : chaque règle est repérée par sa clé (`["deny-ssh"]`) et non par sa position. Retirer une règle ne touche pas les autres ; avec `count`, les index se décalent et des règles sont recréées.
- Avec `prevent_destroy`, `destroy` échoue avant de supprimer quoi que ce soit.

## TP5

- Le fichier de valeurs devient `terraform.tfvars`, chargé automatiquement : `terraform plan` sans `-var-file`. Il sert à dev et à prod, d'où l'abandon du nom `dev.tfvars`.

- Plan : 17 ressources à ajouter (le resource group, plus 8 par appel du module : VNet, 2 sous-réseaux, NSG, 2 règles, 2 associations), et 8 à détruire (le réseau du TP4).
- `init` installe les modules, comme les providers.
- L'ancien réseau est détruit parce que ses adresses dans le state changent (`azurerm_virtual_network.main` devient `module.network_dev.azurerm_virtual_network.this`). Le bloc `moved` (jour 2) évite cette destruction.
- Bonus `cidrsubnet` : `cidrsubnet("10.10.0.0/16", 8, 1)` donne `10.10.1.0/24`.
