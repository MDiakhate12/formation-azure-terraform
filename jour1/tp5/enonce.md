# TP5 : module réseau

**Objectif** : ranger le réseau dans un module, puis l'appeler deux fois. **Durée** : 50 minutes.

## Où on en est, où on va

Votre `rg-<prénom>-dev` contient un VNet, deux sous-réseaux et un NSG, décrits dans `network.tf` et `nsg.tf`.
À la fin de ce TP, ce réseau sera un **module** : un dossier de code réutilisable. Vous l'appellerez deux fois pour obtenir deux réseaux, `dev` et `prod`, dans un nouveau resource group `rg-<prénom>-reseau`.

C'est le TP le plus autonome de la journée : beaucoup d'étapes sont à écrire. Vous continuez dans `~/formation/jour1`.

## Étape 1 : créer le dossier du module

Un module est simplement un dossier de fichiers `.tf`. Votre dossier de travail est lui-même le « module racine ».

**À lancer** :

```bash
# Crée le dossier du module et ses trois fichiers vides
mkdir -p modules/network
touch modules/network/main.tf modules/network/variables.tf modules/network/outputs.tf
```

Sous Windows PowerShell : `mkdir -Force modules\network`, puis créez les trois fichiers depuis VS Code.

Résultat attendu :

```
~/formation/jour1/
├── versions.tf   variables.tf   main.tf   outputs.tf   dev.tfvars
├── network.tf    nsg.tf                  (à vider à l'étape 3)
└── modules/
    └── network/
        ├── main.tf        le réseau : VNet, sous-réseaux, NSG
        ├── variables.tf   ses entrées
        └── outputs.tf     ce qu'il renvoie
```

## Étape 2 : les entrées du module

Dans un module, `var.x` désigne une entrée **du module**, donnée par celui qui l'appelle.

**À copier** dans `modules/network/variables.tf` :

```hcl
variable "prefix" {
  type        = string
  description = "Préfixe des noms de ressources (dev, prod)"
}

variable "subnets" {
  type        = map(string)
  description = "Nom court du sous-réseau vers son CIDR. Doit contenir app."
}
```

**À écrire** dans le même fichier :
- `resource_group_name` et `location`, de type `string` ;
- `address_space`, de type `list(string)` ;
- `nsg_rules` : **coupez** la variable `nsg_rules` de votre `variables.tf` (à la racine) et collez-la ici, avec son `default`.

> [!NOTE]
> **Explication.** Le module ne déclare ni bloc `terraform { }` ni `provider` : il utilise ceux du module racine.

## Étape 3 : déplacer le réseau dans le module

1. **Coupez** tout le contenu de `network.tf` et de `nsg.tf` (à la racine), et collez-le dans `modules/network/main.tf`. Supprimez ensuite les deux fichiers vides.
2. **Supprimez** de `modules/network/main.tf` le NSG `data` et son association (le module reste simple), et la variable `enable_data_nsg` de votre `variables.tf`.
3. **Remplacez**, dans tout `modules/network/main.tf` :

| Avant | Après |
|---|---|
| `azurerm_resource_group.main.name` | `var.resource_group_name` |
| `azurerm_resource_group.main.location` | `var.location` |
| `"vnet-${local.name_prefix}"` | `"vnet-${var.prefix}"` |
| `"nsg-${local.name_prefix}-app"` | `"nsg-${var.prefix}-app"` |
| `resource "azurerm_virtual_network" "main"` | `resource "azurerm_virtual_network" "this"` (et ses références) |

4. **Remplacez** les deux sous-réseaux `app` et `data` par une seule ressource, créée par `for_each` sur la map `subnets`.

**À compléter** :

```hcl
resource "azurerm_subnet" "this" {
  for_each = ...                                  # À COMPLÉTER : la variable des sous-réseaux

  name                 = "snet-${each.key}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [...]                    # À COMPLÉTER : le CIDR de l'élément courant
}
```

5. **À compléter** dans l'association du NSG, qui doit viser le sous-réseau `app` de la map :

```hcl
  subnet_id                 = azurerm_subnet.this[...].id   # À COMPLÉTER : la clé "app", entre guillemets
```

> [!NOTE]
> **Explication.**
> - `"this"` : le nom d'usage quand un module ne contient qu'une ressource de ce type.
> - Avec `for_each`, `azurerm_subnet.this` est une collection : `["app"]` choisit une instance par sa clé.

## Étape 4 : les sorties du module

**À compléter** dans `modules/network/outputs.tf` :

```hcl
output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "subnet_ids" {
  value = { for name, subnet in azurerm_subnet.this : name => ... }   # À COMPLÉTER : l'id du sous-réseau
}
```

> [!NOTE]
> **Explication.** `{ for k, v in collection : k => valeur }` construit une map : ici, le nom de chaque sous-réseau vers son id.

## Étape 5 : alléger la racine

Le réseau a quitté la racine : ce qui le concernait n'y sert plus.

**À faire** :
1. `variables.tf` (racine) : ne gardez que `prenom` et `location`. Supprimez `environment` et `address_space` (`nsg_rules` et `enable_data_nsg` sont déjà partis).
2. `main.tf` : supprimez le bloc `locals`, et nommez le resource group `"rg-${var.prenom}-reseau"`.
3. `dev.tfvars` : ne gardez que la ligne `prenom`.

## Étape 6 : appeler le module deux fois

**À compléter** à la fin de `main.tf` (racine) :

```hcl
module "network_dev" {
  source              = "./modules/network"
  prefix              = "dev"
  resource_group_name = azurerm_resource_group.main.name
  location            = ...                    # À COMPLÉTER : la région du resource group (référence)
  address_space       = ["10.10.0.0/16"]
  subnets = {
    app  = "10.10.1.0/24"
    data = "..."                               # À COMPLÉTER : 10.10.2.0/24
  }
}
```

**À écrire** : un second appel, `network_prod`, avec `prefix = "prod"`, `10.20.0.0/16`, et les sous-réseaux `10.20.1.0/24` et `10.20.2.0/24`.

> [!NOTE]
> **Explication.** `module "nom"` appelle un module. `source` dit où il se trouve (ici un dossier local) ; les autres arguments remplissent ses variables.

## Étape 7 : les sorties de la racine

**À compléter** : remplacez tout le contenu de `outputs.tf` (racine) par :

```hcl
output "dev_vnet" {
  value = module.network_dev.vnet_id
}

output "prod_vnet" {
  value = ...                      # À COMPLÉTER : le vnet_id du module prod
}

output "subnet_ids" {
  value = {
    dev  = module.network_dev.subnet_ids
    prod = module.network_prod.subnet_ids
  }
}
```

> [!NOTE]
> **Explication.** `module.network_dev.vnet_id` lit un output du module : c'est la seule façon de récupérer une valeur de l'intérieur d'un module.

## Étape 8 : initialiser, planifier, appliquer

`init` est obligatoire après l'ajout d'un module : Terraform doit l'installer, comme un provider.

**À lancer** :

```bash
# Installe le module (obligatoire après chaque nouveau module)
terraform init
terraform validate
# Lisez le résumé : ce qui est créé, et ce qui est détruit
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

**Vérifier** : le plan annonce `15 to add` et `8 to destroy`. Les 8 destructions sont l'ancien réseau du TP4 (le resource group `-dev` et son contenu) : c'est normal, et la question ci-dessous y revient.

## Étape 9 : retrouver les deux réseaux dans le portail

1. Ouvrez `rg-<prénom>-reseau` : **Overview** (Vue d'ensemble) liste `vnet-dev`, `vnet-prod`, `nsg-dev-app` et `nsg-prod-app`.
2. Ouvrez `vnet-prod`, menu **Settings > Subnets** (Paramètres > Sous-réseaux) : `snet-app` (`10.20.1.0/24`, avec son NSG) et `snet-data`.
3. Faites de même avec `vnet-dev` : même structure, autres plages. C'est le même module.
4. Vérifiez que `rg-<prénom>-dev` a disparu.

## Documentation

- [Les modules](https://developer.hashicorp.com/terraform/language/modules)
- [L'expression `for`](https://developer.hashicorp.com/terraform/language/expressions/for)
- [`cidrsubnet`](https://developer.hashicorp.com/terraform/language/functions/cidrsubnet)

## Questions

- Combien de ressources contient chaque appel du module ?
- Pourquoi `init` est-il nécessaire après l'ajout d'un module ?
- Le plan détruisait votre ancien réseau. Comment l'éviter ? (Réponse demain, avec le bloc `moved`.)

## Pour aller plus loin

**À écrire** : supprimez la variable `subnets` et calculez les CIDR dans le module. `cidrsubnet(var.address_space[0], 8, 1)` donne le premier `/24` du `/16`, `cidrsubnet(var.address_space[0], 8, 2)` le deuxième.
