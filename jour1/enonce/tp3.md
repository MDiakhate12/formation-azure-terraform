# TP3 : VNet et deux sous-réseaux

**Objectif** : construire le socle réseau du fil rouge. **Durée** : 40 minutes.

## 1. Une variable pour la plage d'adresses

Dans `variables.tf` :

```hcl
variable "address_space" {
  type        = list(string)
  description = "Plage d'adresses du VNet"
  default     = ["10.0.0.0/16"]
}
```

- `list(string)` : une liste de chaînes. Un VNet peut avoir plusieurs plages.
- `10.0.0.0/16` : une plage CIDR de 65 536 adresses (de `10.0.0.0` à `10.0.255.255`).

## 2. Le VNet

Créez `network.tf` :

```hcl
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.name_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.address_space
}
```

- `azurerm_resource_group.main.name` : une **référence** à une autre ressource. Pas de nom recopié à la main.
- Une référence crée aussi une **dépendance** : Terraform créera le resource group avant le VNet.

## 3. Les deux sous-réseaux

```hcl
resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}
```

À vous : `snet-data`, en `10.0.2.0/24`.

- `address_prefixes` : la plage du sous-réseau, incluse dans celle du VNet. Un `/24` fait 256 adresses (Azure en réserve 5).
- Deux sous-réseaux d'un même VNet ne doivent pas se chevaucher.

## 4. Exposer les identifiants

Dans `outputs.tf` :

```hcl
output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "subnet_ids" {
  value = {
    app  = azurerm_subnet.app.id
    data = azurerm_subnet.data.id
  }
}
```

- Un output peut renvoyer une **map** : plusieurs valeurs nommées en un seul output.

## 5. Planifier puis appliquer

```bash
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

## 6. Retrouver le réseau dans le portail

1. Ouvrez `rg-<prénom>-dev` : **Overview** (Vue d'ensemble) liste maintenant `vnet-<prénom>-dev`.
2. Ouvrez le VNet, menu **Settings > Address space** (Paramètres > Espace d'adressage) : `10.0.0.0/16`.
3. Menu **Settings > Subnets** (Paramètres > Sous-réseaux) : `snet-app` et `snet-data`, avec leurs plages et le nombre d'adresses disponibles.

## Questions

- Dans quel ordre Terraform crée-t-il les ressources ? Qui le décide ?
- Combien coûtent un VNet et ses sous-réseaux ?

## Pour aller plus loin

Ajoutez un troisième sous-réseau. Quel CIDR choisissez-vous, et pourquoi ?
