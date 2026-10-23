# TP4 : NSG et règles avec for_each

**Objectif** : filtrer le trafic avec un NSG piloté par une variable. **Durée** : 30 minutes.

## 1. Les règles dans une variable

Dans `variables.tf` :

```hcl
variable "nsg_rules" {
  type = map(object({
    priority = number
    port     = string
    access   = string
  }))
  description = "Règles entrantes du NSG de snet-app, indexées par leur nom"
  default = {
    allow-https = { priority = 100, port = "443", access = "Allow" }
    deny-ssh    = { priority = 200, port = "22", access = "Deny" }
  }
}
```

- `map(object({...}))` : une map dont chaque valeur est un objet avec des champs typés.
- La clé (`allow-https`, `deny-ssh`) servira de nom à la règle.
- `priority` : de 100 à 4096. La plus petite est évaluée en premier.

## 2. Le NSG et ses règles

Créez `nsg.tf` :

```hcl
resource "azurerm_network_security_group" "app" {
  name                = "nsg-${local.name_prefix}-app"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_rule" "app" {
  for_each = var.nsg_rules

  name                        = each.key
  priority                    = each.value.priority
  direction                   = "Inbound"
  access                      = each.value.access
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value.port
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.app.name
}
```

- `for_each` : crée une instance de la ressource **par élément** de la map. Ici, deux règles.
- `each.key` : la clé de l'élément courant. `each.value` : sa valeur (l'objet).
- `direction = "Inbound"` : la règle filtre le trafic entrant. `"*"` : n'importe quelle valeur.

## 3. Associer le NSG au sous-réseau

```hcl
resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}
```

- Un NSG ne filtre rien tant qu'il n'est pas associé à un sous-réseau (ou à une carte réseau).

## 4. Un second NSG, seulement si on le demande

```hcl
variable "enable_data_nsg" {
  type        = bool
  description = "Crée un NSG pour snet-data"
  default     = false
}

resource "azurerm_network_security_group" "data" {
  count = var.enable_data_nsg ? 1 : 0

  name                = "nsg-${local.name_prefix}-data"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
```

À vous : l'association de ce NSG à `snet-data`, avec le même `count`. Référencez le NSG par `azurerm_network_security_group.data[0].id`.

- `count` : le nombre d'instances. `0` : la ressource n'est pas créée.
- `condition ? a : b` : vaut `a` si la condition est vraie, sinon `b`.
- `[0]` : avec `count`, la ressource devient une liste. On prend la première (et seule) instance.

## 5. Comparer les plans

```bash
terraform plan -var-file=dev.tfvars
terraform plan -var-file=dev.tfvars -var="enable_data_nsg=true"
```

## 6. Retrouver le NSG dans le portail

Après un `apply` :

1. Dans `rg-<prénom>-dev`, ouvrez `nsg-<prénom>-dev-app`.
2. Menu **Settings > Inbound security rules** (Paramètres > Règles de sécurité de trafic entrant) : vos règles `allow-https` (100) et `deny-ssh` (200), au-dessus des règles par défaut d'Azure (65000 et plus).
3. Menu **Settings > Subnets** (Paramètres > Sous-réseaux) : le NSG est associé à `snet-app`.
4. Côté VNet, **Subnets** (Sous-réseaux) : la colonne **Security group** (Groupe de sécurité) indique `nsg-<prénom>-dev-app` pour `snet-app`, rien pour `snet-data`.

## Documentation

- [`azurerm_network_security_group`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)
- [`azurerm_network_security_rule`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule)
- [`azurerm_subnet_network_security_group_association`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association)
- [`for_each`](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each)
- [`count`](https://developer.hashicorp.com/terraform/language/meta-arguments/count)

## Questions

- Comment s'appelle chaque règle dans le state (`terraform state list`) ?
- Pourquoi `for_each` plutôt que `count` pour les règles ?

## Pour aller plus loin

Protégez le NSG de `snet-app`, puis lancez `terraform destroy` :

```hcl
  lifecycle {
    prevent_destroy = true
  }
```
