# TP5 : module réseau

**Objectif** : mutualiser le réseau dans un module appelé deux fois. **Durée** : 50 minutes.

## 1. La structure

```
.
├── versions.tf
├── variables.tf          prenom, location
├── main.tf               le resource group et les deux appels du module
├── outputs.tf
└── modules/
    └── network/
        ├── main.tf       VNet, sous-réseaux, NSG, règles, association
        ├── variables.tf  les entrées du module
        └── outputs.tf    ce que le module renvoie
```

- Un **module** est simplement un dossier de fichiers `.tf`. Votre dossier de travail est lui-même le module racine.
- Le module ne déclare ni `terraform { }` ni `provider` : il hérite de ceux de la racine.

## 2. Les entrées du module

`modules/network/variables.tf` :

```hcl
variable "prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnets" {
  type        = map(string)
  description = "Nom court du sous-réseau vers son CIDR. Doit contenir app."
}
```

À vous : `location` (`string`), `address_space` (`list(string)`) et `nsg_rules` (reprenez celle du TP4, avec son `default`).

- Dans un module, `var.x` désigne les entrées **du module**, données par celui qui l'appelle.

## 3. Le contenu du module

Déplacez VNet, sous-réseaux, NSG, règles et association dans `modules/network/main.tf`. Remplacez les références au resource group par `var.resource_group_name` et `var.location`.

Les sous-réseaux sont maintenant créés par `for_each` :

```hcl
resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = "snet-${each.key}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value]
}
```

L'association du NSG vise le sous-réseau `app` de la map : `azurerm_subnet.this["app"].id`.

- `"this"` : nom d'usage quand un module ne contient qu'une ressource de ce type.
- `["app"]` : avec `for_each`, on choisit une instance par sa clé.

## 4. Les sorties du module

`modules/network/outputs.tf` :

```hcl
output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "subnet_ids" {
  value = { for name, subnet in azurerm_subnet.this : name => subnet.id }
}
```

- `{ for k, v in ... : k => v }` : une expression `for` qui construit une map (ici, nom du sous-réseau vers son id).

## 5. Appeler le module deux fois

À la racine, `main.tf` garde le resource group (renommez-le `rg-<prénom>-reseau`) et appelle le module :

```hcl
module "network_dev" {
  source              = "./modules/network"
  prefix              = "dev"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.10.0.0/16"]
  subnets = {
    app  = "10.10.1.0/24"
    data = "10.10.2.0/24"
  }
}
```

À vous : `network_prod`, avec `prefix = "prod"`, `10.20.0.0/16`, `10.20.1.0/24` et `10.20.2.0/24`.

- `module "nom"` : un appel de module. `source` : où il se trouve (ici un dossier local).
- Les autres arguments remplissent les variables du module.

## 6. Initialiser, planifier, exposer

```bash
terraform init                      # obligatoire après l'ajout d'un module
terraform plan -var-file=dev.tfvars
```

Dans `outputs.tf` à la racine :

```hcl
output "dev_vnet" {
  value = module.network_dev.vnet_id
}
```

À vous : `prod_vnet`, puis `apply`.

- `module.network_dev.vnet_id` : lit un output du module.

## Questions

- Combien de ressources le plan va-t-il créer ?
- Pourquoi `init` est-il nécessaire après l'ajout d'un module ?
- Le plan veut détruire votre ancien réseau. Comment l'éviter ? (Réponse demain, avec le bloc `moved`.)

## Pour aller plus loin

Supprimez la variable `subnets` et calculez les CIDR dans le module : `cidrsubnet(var.address_space[0], 8, 1)` donne le premier `/24` du `/16`.
