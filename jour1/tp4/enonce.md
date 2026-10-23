# TP4 : NSG et règles avec for_each

**Objectif** : filtrer le trafic d'un sous-réseau avec un NSG piloté par une variable. **Durée** : 30 minutes.

## Où on en est, où on va

Votre resource group contient un VNet et deux sous-réseaux, ouverts à tout.
À la fin de ce TP, `snet-app` sera protégé par un **NSG** (Network Security Group, le pare-feu d'Azure) : HTTPS autorisé, SSH refusé.
Les règles viendront d'une variable : en ajouter une ne demandera aucune nouvelle ressource dans le code.

Vous continuez dans `~/formation/jour1`.

## Étape 1 : les règles dans une variable

**À compléter** à la fin de `variables.tf` :

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
    deny-ssh    = { priority = ..., port = "...", access = "..." }   # À COMPLÉTER : priorité 200, port 22, refusé (Deny)
  }
}
```

> [!NOTE]
> **Explication.**
> - `map(object({...}))` : une map dont chaque valeur est un objet aux champs typés. La clé (`allow-https`, `deny-ssh`) servira de nom à la règle.
> - `priority` : de 100 à 4096. La règle à la plus petite priorité est évaluée en premier.

## Étape 2 : le NSG

**À compléter** dans un nouveau fichier `nsg.tf` :

```hcl
resource "azurerm_network_security_group" "app" {
  name                = "nsg-${local.name_prefix}-app"
  location            = ...                 # À COMPLÉTER : la région du resource group (référence)
  resource_group_name = ...                 # À COMPLÉTER : le nom du resource group (référence)
}
```

## Étape 3 : toutes les règles avec une seule ressource

`for_each` crée une instance de la ressource **par élément** de la map : ici, une règle par entrée de `nsg_rules`.

**À compléter** à la suite, dans `nsg.tf` :

```hcl
resource "azurerm_network_security_rule" "app" {
  for_each = var.nsg_rules

  name                        = each.key
  priority                    = each.value.priority
  direction                   = "Inbound"
  access                      = ...          # À COMPLÉTER : le champ access de l'élément courant
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = ...          # À COMPLÉTER : le champ port de l'élément courant
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = ...          # À COMPLÉTER : le nom du NSG de l'étape 2
}
```

> [!NOTE]
> **Explication.**
> - `each.key` : la clé de l'élément courant (`allow-https`). `each.value` : sa valeur, l'objet ; `each.value.priority` en lit un champ.
> - `direction = "Inbound"` : la règle filtre le trafic **entrant**. `"*"` : n'importe quelle valeur.

## Étape 4 : associer le NSG au sous-réseau

Un NSG ne filtre rien tant qu'il n'est pas associé à un sous-réseau.

**À écrire** à la suite, dans `nsg.tf` : une ressource `azurerm_subnet_network_security_group_association` nommée `app`, avec deux arguments :
- `subnet_id` : l'id de `snet-app` ;
- `network_security_group_id` : l'id du NSG de l'étape 2.

## Étape 5 : un second NSG, seulement si on le demande

`count` fixe le nombre d'instances d'une ressource : avec `0`, elle n'est pas créée.

**À écrire** à la fin de `variables.tf` : une variable `enable_data_nsg`, de type `bool`, avec `description = "Crée un NSG pour snet-data"` et `false` par défaut.

**À compléter** à la fin de `nsg.tf` :

```hcl
resource "azurerm_network_security_group" "data" {
  count = var.enable_data_nsg ? ... : ...   # À COMPLÉTER : 1 si la variable vaut true, sinon 0

  name                = "nsg-${local.name_prefix}-data"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
```

**À écrire** : l'association de ce NSG à `snet-data`, nommée `data`, avec le même `count`. Pour son id, utilisez `azurerm_network_security_group.data[0].id`.

> [!NOTE]
> **Explication.**
> - `condition ? a : b` vaut `a` si la condition est vraie, sinon `b`.
> - Avec `count`, la ressource devient une **liste** : `[0]` désigne sa première (et seule) instance.

## Étape 6 : comparer les plans

La première commande garde la valeur par défaut (`false`), la seconde force `enable_data_nsg` à `true`.

**À lancer** :

```bash
# Plan sans le NSG data
terraform plan -var-file=dev.tfvars
# Plan avec le NSG data : deux ressources de plus
terraform plan -var-file=dev.tfvars -var="enable_data_nsg=true"
# Applique la version sans NSG data (tapez yes)
terraform apply -var-file=dev.tfvars
```

**Vérifier** : le premier plan annonce `4 to add` (le NSG, ses deux règles, l'association), le second `6 to add`.

## Étape 7 : retrouver le NSG dans le portail

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

Protégez le NSG de `snet-app`, puis lancez `terraform destroy -var-file=dev.tfvars` : que se passe-t-il ?

**À copier** dans le bloc `azurerm_network_security_group` `app` :

```hcl
  lifecycle {
    prevent_destroy = true
  }
```

Retirez ensuite ce bloc : le TP5 en a besoin.
