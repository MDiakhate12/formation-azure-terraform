# TP3 : VNet et deux sous-réseaux

**Objectif** : construire le socle réseau du fil rouge. **Durée** : 40 minutes.

## Où on en est, où on va

Vous avez un resource group `rg-<prénom>-dev`, nommé par variables.
À la fin de ce TP, il contiendra un réseau virtuel (VNet) et deux sous-réseaux : `snet-app` pour les applications, `snet-data` pour les données.
Le TP4 les protégera, le TP5 en fera un module réutilisable.

Vous continuez dans `~/formation/jour1`.

## Étape 1 : une variable pour la plage d'adresses

La plage d'adresses du VNet devient une variable, pour pouvoir la changer sans toucher au code.

**À compléter** à la fin de `variables.tf` :

```hcl
variable "address_space" {
  type        = list(...)               # À COMPLÉTER : une liste de chaînes de caractères
  description = "Plage d'adresses du VNet"
  default     = ["..."]                 # À COMPLÉTER : 10.0.0.0/16
}
```

> [!NOTE]
> **Explication.**
> - `list(string)` : une liste de chaînes. Un VNet peut avoir plusieurs plages, d'où la liste.
> - `10.0.0.0/16` : une plage CIDR de 65 536 adresses (de `10.0.0.0` à `10.0.255.255`). Le `/16` dit que les 16 premiers bits sont fixes.

## Étape 2 : le VNet

**À compléter** dans un nouveau fichier `network.tf` :

```hcl
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${...}"                      # À COMPLÉTER : le local du TP2, comme pour le resource group
  location            = azurerm_resource_group.main.location
  resource_group_name = ...                                # À COMPLÉTER : le nom du resource group, sur le modèle de la ligne du dessus
  address_space       = ...                                # À COMPLÉTER : la variable de l'étape 1
}
```

> [!NOTE]
> **Explication.**
> - `azurerm_resource_group.main.location` est une **référence** : on lit la région du resource group au lieu de la recopier.
> - Une référence crée aussi une **dépendance** : Terraform sait qu'il doit créer le resource group avant le VNet.

## Étape 3 : les deux sous-réseaux

**À compléter** à la suite, dans `network.tf` :

```hcl
resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = ...              # À COMPLÉTER : le nom du VNet de l'étape 2 (référence)
  address_prefixes     = ["10.0.1.0/24"]
}
```

**À écrire** : le second sous-réseau, `azurerm_subnet` nommé `data` dans le code, `snet-data` dans Azure, en `10.0.2.0/24`. Même structure que `app`.

> [!NOTE]
> **Explication.**
> - `address_prefixes` : la plage du sous-réseau, incluse dans celle du VNet. Un `/24` fait 256 adresses, dont 5 réservées par Azure.
> - Deux sous-réseaux d'un même VNet ne doivent pas se chevaucher : `10.0.1.0/24` et `10.0.2.0/24` sont bien séparés.

## Étape 4 : exposer les identifiants

**À compléter** à la fin de `outputs.tf` :

```hcl
output "vnet_id" {
  value = ...                       # À COMPLÉTER : l'id du VNet
}

output "subnet_ids" {
  value = {
    app  = azurerm_subnet.app.id
    data = ...                      # À COMPLÉTER : l'id du sous-réseau data
  }
}
```

> [!NOTE]
> **Explication.** Un output peut renvoyer une **map** `{ clé = valeur }` : plusieurs valeurs nommées en un seul output.

## Étape 5 : planifier, puis appliquer

**À lancer** :

```bash
# Remet le code en forme, puis vérifie la syntaxe
terraform fmt
terraform validate
# Montre ce qui va être créé : lisez l'ordre des ressources
terraform plan -var-file=dev.tfvars
# Crée le réseau (tapez yes)
terraform apply -var-file=dev.tfvars
```

**Vérifier** : le plan annonce `3 to add` (le VNet et les deux sous-réseaux). Le resource group existe déjà : il n'est pas recréé.

## Étape 6 : retrouver le réseau dans le portail

1. Ouvrez `rg-<prénom>-dev` : **Overview** (Vue d'ensemble) liste maintenant `vnet-<prénom>-dev`.
2. Ouvrez le VNet, menu **Settings > Address space** (Paramètres > Espace d'adressage) : `10.0.0.0/16`.
3. Menu **Settings > Subnets** (Paramètres > Sous-réseaux) : `snet-app` et `snet-data`, avec leurs plages et le nombre d'adresses disponibles.

## Documentation

- [`azurerm_virtual_network`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)
- [`azurerm_subnet`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)
- [Les références entre ressources](https://developer.hashicorp.com/terraform/language/expressions/references)

## Questions

- Dans quel ordre Terraform crée-t-il les ressources ? Qui le décide ?
- Combien coûtent un VNet et ses sous-réseaux ?

## Pour aller plus loin

**À écrire** : un troisième sous-réseau. Quel CIDR choisissez-vous, et pourquoi ?
