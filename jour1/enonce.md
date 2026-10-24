# Jour 1 : énoncé

## Table des matières

| Partie | Sujet | Durée |
|---|---|---|
| [Prérequis](#lire-les-énoncés) | Lire les énoncés, se connecter à Azure | 5 min |
| [TP1](#tp1--mon-premier-resource-group) | Mon premier resource group | 30 min |
| [TP2](#tp2--variabiliser-et-nommer) | Variabiliser et nommer | 30 min |
| [TP3](#tp3--vnet-et-deux-sous-réseaux) | VNet et deux sous-réseaux | 40 min |
| [TP4](#tp4--nsg-et-règles-avec-for_each) | NSG et règles avec `for_each` | 30 min |
| [TP5](#tp5--module-réseau) | Module réseau | 50 min |
| [Bonus](#bonus--une-vm-configurée-par-cloud-init) | Une VM configurée par cloud-init | 30 min |

Un fil rouge sur la journée : un resource group, puis un réseau, puis un module réutilisable.
Vous travaillez **dans le dossier `jour1/` du dépôt cloné**, du TP1 au TP5 : le même code évolue de TP en TP, avec un seul state.

Bloqué ? La solution de chaque TP est publiée juste après sa correction dans `jour1/solutions/tpN/` : `git pull`, puis copiez son contenu dans `jour1/` et repartez de là.

## Lire les énoncés

Chaque étape d'un TP commence par une phrase qui dit **pourquoi** on la fait, puis un ou plusieurs repères :

| Repère | Ce que vous faites |
|---|---|
| **À copier** | Recopiez le bloc tel quel dans le fichier indiqué. C'est du code déjà prêt (souvent un prérequis). |
| **À compléter** | Recopiez le bloc, puis remplacez chaque `...` : le commentaire `# À COMPLÉTER : ...` sur la même ligne dit quoi mettre. |
| **À écrire** | Écrivez le bloc vous-même, à partir de la consigne et du modèle des étapes précédentes. |
| **À lancer** | Tapez les commandes dans le terminal, dans votre dossier de travail, une par une. La ligne `#` au-dessus de chaque commande dit ce qu'elle fait. |
| **Vérifier** | Ce que vous devez obtenir. Si ce n'est pas le cas, arrêtez-vous et demandez. |

> **Explication.** Les citations comme celle-ci expliquent le code ou les commandes. Ils sont à lire : il n'y a rien à faire.

Les TP deviennent plus autonomes au fil de la journée : beaucoup de code à copier au TP1, de plus en plus à compléter puis à écrire ensuite.

### La notation `<...>`

Tout ce qui est entre chevrons `< >` est à **remplacer entièrement, chevrons compris**, par votre propre valeur.

| Dans l'énoncé | Ce que vous écrivez (exemple pour Alexandre) |
|---|---|
| `rg-<prénom>-tf` | `rg-alexandre-tf` |
| `prenom = "<prénom>"` | `prenom = "alexandre"` (les guillemets restent) |
| `az login --tenant <tenant>` | `az login --tenant 1a2b3c4d-...` (l'identifiant collé par le formateur dans le chat) |

Votre prénom s'écrit **en minuscules, sans accent, sans espace ni tiret** : Hélène devient `helene`, Jean-Marc devient `jeanmarc`.
Il sert à reconnaître vos ressources dans la subscription partagée : deux participants ne doivent jamais avoir le même nom.

## Avant de commencer

Le formateur colle dans le chat un bloc prêt à l'emploi : copiez-le tel quel. Sinon, remplacez `<tenant>` par l'id du tenant qu'il vous donne.

### macOS, Linux, Git Bash

```bash
az login --tenant <tenant>
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo $ARM_SUBSCRIPTION_ID
```

### Windows PowerShell

```powershell
az login --tenant <tenant>
$env:ARM_SUBSCRIPTION_ID = (az account show --query id -o tsv)
$env:ARM_SUBSCRIPTION_ID
```

La dernière ligne doit afficher un identifiant (`xxxxxxxx-xxxx-...`).

> **À refaire dans chaque nouveau terminal.** La variable n'existe que dans le terminal où vous l'avez définie.
> Nouvel onglet, nouvelle fenêtre, terminal de VS Code : relancez la ligne `export` (ou `$env:...`). `az login` n'est pas à refaire.
> Si vous l'oubliez, `terraform plan` échoue avec : `subscription_id is a required provider property`.

Pour ne plus y penser, ajoutez-la au démarrage de vos terminaux (à retirer après la formation) :

- macOS (zsh) : `echo 'export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)' >> ~/.zshrc`
- Windows : `setx ARM_SUBSCRIPTION_ID (az account show --query id -o tsv)`, valable pour les **prochains** terminaux uniquement.

## Le portail Azure

Ouvrez le lien d'invitation reçu par e-mail, ou `https://portal.azure.com/<tenant>`.
Vous êtes **invité** dans le tenant de la formation : si le portail affiche votre propre annuaire, changez-en.
Icône engrenage (Settings / Paramètres), puis **Directories + subscriptions** (Annuaires + abonnements), et choisissez le tenant de la formation.

Pour retrouver une ressource : tapez son nom dans la barre de recherche en haut, ou ouvrez **Resource groups** (Groupes de ressources).
Le portail est en anglais ou en français selon vos réglages : les deux libellés sont donnés.

Sans le portail, la CLI suffit : `az resource list -g <resource group> -o table`.

## Règles de la subscription partagée

- Préfixez **toutes** vos ressources par votre prénom, en minuscules et sans accent.
- Région unique : `swedencentral`. Taille de VM autorisée : `Standard_D2as_v6`. Une policy refuse le reste.
- Détruisez ce qui coûte (la VM du bonus) avant de partir.

## Cliquer pour naviguer vers un TP

| TP | Sujet | Durée |
|---|---|---|
| [TP1](#tp1--mon-premier-resource-group) | Mon premier resource group | 30 min |
| [TP2](#tp2--variabiliser-et-nommer) | Variabiliser et nommer | 30 min |
| [TP3](#tp3--vnet-et-deux-sous-réseaux) | VNet et deux sous-réseaux | 40 min |
| [TP4](#tp4--nsg-et-règles-avec-for_each) | NSG et règles avec `for_each` | 30 min |
| [TP5](#tp5--module-réseau) | Module réseau | 50 min |
| [Bonus](#bonus--une-vm-configurée-par-cloud-init) | Une VM configurée par cloud-init | 30 min |

## TP1 : mon premier resource group

<details>
<summary><b>Afficher l'énoncé du TP1</b></summary>

**Objectif** : créer, puis détruire, un resource group avec Terraform. **Durée** : 30 minutes.
**Dossier de travail** : `jour1/`
Avant de commencer, lisez la partie [Lire les énoncés](#lire-les-énoncés), plus haut : elle explique les repères **À copier**, **À compléter**, **À lancer** et la notation `<prénom>`.

### Où on en est, où on va

Rien n'existe encore. À la fin de ce TP, vous aurez créé un resource group `rg-<prénom>-tf` dans Azure, uniquement avec du code.
C'est le premier maillon du fil rouge : tout le réseau de la journée viendra s'y ranger.

#### Étape 1 : vous placer dans le dossier et vous connecter

Terraform lit tous les fichiers `.tf` du dossier où vous le lancez : pour toute la journée, ce sera `jour1/`.

**À lancer** (macOS, Linux, Git Bash) :

```bash
# Depuis la racine du dépôt cloné : toutes les commandes du jour se lancent dans jour1/
cd jour1
```

Connectez-vous ensuite avec le bloc du [plus haut](#avant-de-commencer) (`az login`, puis la variable `ARM_SUBSCRIPTION_ID`).

**Vérifier** : `echo $ARM_SUBSCRIPTION_ID` (ou `$env:ARM_SUBSCRIPTION_ID` sous PowerShell) affiche un identifiant.

Ouvrez ce dossier dans VS Code : `code .`

### Étape 2 : déclarer Terraform et le provider

Terraform ne connaît aucun cloud : il lui faut un plugin, le **provider**, pour parler à Azure.

**À copier** dans un nouveau fichier `versions.tf` :

```hcl
terraform {
  required_version = ">= 1.15.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

> **Explication.**
> - `terraform { }` : les réglages de Terraform lui-même. `required_version` : la version minimale acceptée.
> - `required_providers` : les plugins à télécharger. `source` dit où les trouver, `version` lesquelles accepter (`~> 5.0` : toute version 5.x, jamais 6.0).
> - `provider "azurerm"` : la connexion à Azure. `features {}` est obligatoire, même vide. La subscription est lue dans `ARM_SUBSCRIPTION_ID`.

### Étape 3 : décrire le resource group

Un resource group est un conteneur : il range des ressources qui vivent et meurent ensemble.

**À compléter** dans un nouveau fichier `main.tf` :

```hcl
resource "azurerm_resource_group" "main" {
  name     = "rg-<prénom>-tf"   # À COMPLÉTER : remplacez <prénom>, par exemple rg-alexandre-tf
  location = "..."              # À COMPLÉTER : la seule région autorisée, swedencentral
}
```

> **Explication.**
> - `resource` : une ressource que Terraform crée et gère.
> - `"azurerm_resource_group"` : son type, fourni par le provider. `"main"` : son nom **dans le code**, pour y faire référence plus tard.
> - `name` : son nom **dans Azure**, celui que vous verrez dans le portail. `location` : sa région.

### Étape 4 : le cycle de vie Terraform

Ces cinq commandes reviendront dans tous les TP. Lancez-les une par une et lisez ce qu'elles affichent.

**À lancer** :

```bash
# Télécharge le provider azurerm dans le dossier .terraform/ (une fois par dossier)
terraform init
# Remet le code en forme : indentation, alignement des =
terraform fmt
# Vérifie la syntaxe, sans contacter Azure
terraform validate
# Montre ce que Terraform va faire, sans rien changer
terraform plan
# Fait réellement les changements : tapez yes pour confirmer
terraform apply
```

**Vérifier** :
- `plan` annonce `Plan: 1 to add, 0 to change, 0 to destroy`.
- `apply` se termine par `Apply complete! Resources: 1 added`.

Erreur `RequestDisallowedByPolicy` ? La région n'est pas `swedencentral` (attention à l'orthographe exacte) : la policy de la formation la refuse.

### Étape 5 : retrouver le resource group dans le portail

1. Ouvrez [portal.azure.com](https://portal.azure.com), dans le tenant de la formation (voir le [plus haut](#le-portail-azure)).
2. Barre de recherche en haut : tapez **Resource groups** (Groupes de ressources), ouvrez le service.
3. Filtrez sur votre prénom : `rg-<prénom>-tf` apparaît, en **Sweden Central**.
4. Ouvrez-le : **Overview** (Vue d'ensemble) est vide, c'est normal, il ne contient encore rien.

### Étape 6 : détruire et recommencer

**À lancer** :

```bash
# Supprime tout ce que Terraform a créé dans ce dossier (tapez yes)
terraform destroy
# Recrée exactement la même infrastructure, à partir du même code
terraform apply
```

**Vérifier** : actualisez la liste des resource groups entre les deux commandes. Le vôtre disparaît, puis revient.
Gardez-le : le TP2 part de lui.

### Documentation

- [`azurerm_resource_group`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)
- [Le provider azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Les commandes Terraform](https://developer.hashicorp.com/terraform/cli/commands)

### Questions

- Qu'a créé `terraform init` dans votre dossier ?
- Dans le plan, que signifie le symbole `+` ?

### Pour aller plus loin

Ajoutez un tag au resource group, puis lancez `terraform plan` : quel symbole apparaît ?

**À copier** dans le bloc `azurerm_resource_group`, sous `location` :

```hcl
  tags = {
    owner = "<prénom>"
  }
```

Après l'`apply`, ouvrez le resource group, menu **Tags** (Étiquettes) : `owner` y est.

</details>

## TP2 : variabiliser et nommer

<details>
<summary><b>Afficher l'énoncé du TP2</b></summary>

**Objectif** : remplacer les valeurs écrites en dur par des variables, des locals et des outputs. **Durée** : 30 minutes.
**Dossier de travail** : `jour1/`

### Où on en est, où on va

Vous avez un resource group `rg-<prénom>-tf`, mais son nom et sa région sont écrits en dur dans `main.tf`.
À la fin de ce TP, le même code servira à plusieurs environnements : le nom sera calculé à partir de votre prénom et de l'environnement (`rg-<prénom>-dev`).

> **Avant de commencer** : dans `jour1/`, lancez `terraform state list`. La liste doit montrer les ressources du TP précédent.
> Liste vide ? Vous n'êtes pas dans le bon dossier : revenez dans `jour1/` (`cd` depuis la racine du dépôt).

### Étape 1 : déclarer les variables

Une variable est une **entrée** du code : sa valeur est donnée au lancement, pas écrite dans le code.

**À copier** dans un nouveau fichier `variables.tf` :

```hcl
variable "prenom" {
  type        = string
  description = "Votre prénom, en minuscules et sans accent : il préfixe toutes vos ressources."

  validation {
    condition     = can(regex("^[a-z]{2,12}$", var.prenom))
    error_message = "2 à 12 lettres minuscules, sans accent ni tiret."
  }
}

variable "environment" {
  type        = string
  description = "Nom de l'environnement"
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Valeurs permises : dev ou prod."
  }
}
```

**À compléter** dans le même fichier, à la suite :

```hcl
variable "location" {
  type        = ...           # À COMPLÉTER : le même type que les deux autres variables
  description = "Région Azure"
  default     = "..."         # À COMPLÉTER : la région de la formation
}
```

> **Explication.**
> - `type` : le type attendu (`string`, `number`, `bool`, `list(...)`, `map(...)`).
> - `default` : la valeur utilisée si personne n'en donne. `prenom` n'en a pas : Terraform devra la recevoir.
> - `validation` : une règle vérifiée avant le plan. Si `condition` est fausse, `error_message` s'affiche.
> - `contains(liste, valeur)` : vrai si la valeur est dans la liste.
> - `regex(motif, texte)` échoue si le texte ne respecte pas le motif, et `can(...)` transforme cet échec en `false`. Ici : 2 à 12 lettres minuscules.

### Étape 2 : calculer le nom, utiliser les variables

Un local est une valeur **calculée** une fois et réutilisée partout.

**À compléter** : remplacez tout le contenu de `main.tf` par :

```hcl
locals {
  name_prefix = "${var.prenom}-${...}"   # À COMPLÉTER : la variable de l'environnement
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}"
  location = ...                         # À COMPLÉTER : la variable de la région, sans guillemets
}
```

> **Explication.**
> - `var.x` lit une variable, `local.x` lit un local.
> - `"${...}"` insère une valeur dans une chaîne : avec `alexandre` et `dev`, `name_prefix` vaut `alexandre-dev`, et le nom devient `rg-alexandre-dev`.
> - Une valeur seule (`var.location`) s'écrit **sans** guillemets : avec des guillemets, ce serait le texte « var.location ».

### Étape 3 : exposer un résultat

Un output affiche une valeur à la fin de l'`apply` : c'est la « sortie » du code.

**À compléter** dans un nouveau fichier `outputs.tf` :

```hcl
output "resource_group_id" {
  value = ...   # À COMPLÉTER : l'id du resource group, sous la forme type.nom.attribut
}
```

> **Explication.** `azurerm_resource_group.main.id` se lit : type de la ressource, puis son nom dans le code, puis l'attribut. L'`id` n'est connu qu'une fois la ressource créée.

### Étape 4 : un fichier de valeurs

Les valeurs des variables se rangent dans un fichier `.tfvars`, un par environnement.

**À compléter** dans un nouveau fichier `dev.tfvars` :

```hcl
prenom      = "<prénom>"   # À COMPLÉTER : votre prénom, par exemple "alexandre"
environment = "dev"
```

> **Explication.** Un `.tfvars` ne contient que des valeurs, pas de code. Terraform ne le lit que si vous le lui indiquez avec `-var-file` (sauf s'il s'appelle exactement `terraform.tfvars`).

### Étape 5 : planifier avec ce fichier

La première commande lit les valeurs de `dev.tfvars`. La seconde donne en plus une valeur directement dans la ligne de commande, pour voir laquelle l'emporte.

**À lancer** :

```bash
# Plan avec les valeurs de dev.tfvars
terraform plan -var-file=dev.tfvars
# Même plan, mais l'environnement est forcé à prod dans la commande
terraform plan -var-file=dev.tfvars -var="environment=prod"
```

**Vérifier** :
- Le premier plan affiche `-/+` et `forces replacement` : le nom passe de `rg-<prénom>-tf` à `rg-<prénom>-dev`.
- Le second affiche `rg-<prénom>-prod`.

### Étape 6 : appliquer et vérifier dans le portail

**À lancer** :

```bash
# Applique avec les valeurs de dev.tfvars (tapez yes)
terraform apply -var-file=dev.tfvars
# Réaffiche les outputs à tout moment
terraform output resource_group_id
```

Dans le portail :

1. **Resource groups** (Groupes de ressources) : `rg-<prénom>-tf` a disparu, `rg-<prénom>-dev` l'a remplacé.
2. Ouvrez `rg-<prénom>-dev`, puis **JSON View** (Vue JSON), en haut à droite de la vue d'ensemble.
3. Le champ `id` est le même que celui affiché par `terraform output`.

À partir de maintenant, ajoutez toujours `-var-file=dev.tfvars` à `plan` et `apply`.

### Documentation

- [Les variables](https://developer.hashicorp.com/terraform/language/values/variables)
- [Les locals](https://developer.hashicorp.com/terraform/language/values/locals)
- [Les outputs](https://developer.hashicorp.com/terraform/language/values/outputs)

### Questions

- Le plan veut remplacer le resource group du TP1 (`-/+`). Pourquoi ?
- Avec `-var-file` et `-var` à la fois, quelle valeur gagne ?
- Que se passe-t-il si vous oubliez `-var-file` ?

### Pour aller plus loin

Faites échouer la validation volontairement, puis lisez le message :

```bash
# environment=test n'est pas dans la liste autorisée
terraform plan -var-file=dev.tfvars -var="environment=test"
```

</details>

## TP3 : VNet et deux sous-réseaux

<details>
<summary><b>Afficher l'énoncé du TP3</b></summary>

**Objectif** : construire le socle réseau du fil rouge. **Durée** : 40 minutes.
**Dossier de travail** : `jour1/`

### Où on en est, où on va

Vous avez un resource group `rg-<prénom>-dev`, nommé par variables.
À la fin de ce TP, il contiendra un réseau virtuel (VNet) et deux sous-réseaux : `snet-app` pour les applications, `snet-data` pour les données.
Le TP4 les protégera, le TP5 en fera un module réutilisable.

> **Avant de commencer** : dans `jour1/`, lancez `terraform state list`. La liste doit montrer les ressources du TP précédent.
> Liste vide ? Vous n'êtes pas dans le bon dossier : revenez dans `jour1/` (`cd` depuis la racine du dépôt).

### Étape 1 : une variable pour la plage d'adresses

La plage d'adresses du VNet devient une variable, pour pouvoir la changer sans toucher au code.

**À compléter** à la fin de `variables.tf` :

```hcl
variable "address_space" {
  type        = list(...)               # À COMPLÉTER : une liste de chaînes de caractères
  description = "Plage d'adresses du VNet"
  default     = ["..."]                 # À COMPLÉTER : 10.0.0.0/16
}
```

> **Explication.**
> - `list(string)` : une liste de chaînes. Un VNet peut avoir plusieurs plages, d'où la liste.
> - `10.0.0.0/16` : une plage CIDR de 65 536 adresses (de `10.0.0.0` à `10.0.255.255`). Le `/16` dit que les 16 premiers bits sont fixes.

### Étape 2 : le VNet

**À compléter** dans un nouveau fichier `network.tf` :

```hcl
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${...}"                      # À COMPLÉTER : le local du TP2, comme pour le resource group
  location            = azurerm_resource_group.main.location
  resource_group_name = ...                                # À COMPLÉTER : le nom du resource group, sur le modèle de la ligne du dessus
  address_space       = ...                                # À COMPLÉTER : la variable de l'étape 1
}
```

> **Explication.**
> - `azurerm_resource_group.main.location` est une **référence** : on lit la région du resource group au lieu de la recopier.
> - Une référence crée aussi une **dépendance** : Terraform sait qu'il doit créer le resource group avant le VNet.

### Étape 3 : les deux sous-réseaux

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

> **Explication.**
> - `address_prefixes` : la plage du sous-réseau, incluse dans celle du VNet. Un `/24` fait 256 adresses, dont 5 réservées par Azure.
> - Deux sous-réseaux d'un même VNet ne doivent pas se chevaucher : `10.0.1.0/24` et `10.0.2.0/24` sont bien séparés.

### Étape 4 : exposer les identifiants

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

> **Explication.** Un output peut renvoyer une **map** `{ clé = valeur }` : plusieurs valeurs nommées en un seul output.

### Étape 5 : planifier, puis appliquer

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

### Étape 6 : retrouver le réseau dans le portail

1. Ouvrez `rg-<prénom>-dev` : **Overview** (Vue d'ensemble) liste maintenant `vnet-<prénom>-dev`.
2. Ouvrez le VNet, menu **Settings > Address space** (Paramètres > Espace d'adressage) : `10.0.0.0/16`.
3. Menu **Settings > Subnets** (Paramètres > Sous-réseaux) : `snet-app` et `snet-data`, avec leurs plages et le nombre d'adresses disponibles.

### Documentation

- [`azurerm_virtual_network`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)
- [`azurerm_subnet`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)
- [Les références entre ressources](https://developer.hashicorp.com/terraform/language/expressions/references)

### Questions

- Dans quel ordre Terraform crée-t-il les ressources ? Qui le décide ?
- Combien coûtent un VNet et ses sous-réseaux ?

### Bonus : voir le graphe des dépendances

Terraform peut dessiner l'ordre qu'il a déduit de vos références.

**À lancer** dans `jour1/` :

```bash
# Écrit le graphe des ressources au format DOT (Graphviz)
terraform graph > graph.dot
```

Sous Windows PowerShell 5, le `>` écrit dans un encodage que les visualiseurs lisent mal : utilisez plutôt `terraform graph | Out-File -Encoding utf8 graph.dot`.

**Pour l'afficher**, au choix :

- dans VS Code, avec l'extension **Graphviz Interactive Preview** : ouvrez `graph.dot`, puis la palette de commandes (Ctrl+Maj+P, ou Cmd+Maj+P sur Mac) et « Graphviz Interactive: Preview » ;
- en ligne, sans rien installer : collez le contenu de `graph.dot` dans [Graphviz Online](https://dreampuf.github.io/GraphvizOnline).

**Vérifier** : une flèche part de chaque sous-réseau vers le VNet, et du VNet vers le resource group. Rien ne relie `snet-app` à `snet-data` : c'est pour cela que Terraform les crée en même temps.

### Pour aller plus loin

**À écrire** : un troisième sous-réseau. Quel CIDR choisissez-vous, et pourquoi ?

</details>

## TP4 : NSG et règles avec for_each

<details>
<summary><b>Afficher l'énoncé du TP4</b></summary>

**Objectif** : filtrer le trafic d'un sous-réseau avec un NSG piloté par une variable. **Durée** : 30 minutes.
**Dossier de travail** : `jour1/`

### Où on en est, où on va

Votre resource group contient un VNet et deux sous-réseaux, ouverts à tout.
À la fin de ce TP, `snet-app` sera protégé par un **NSG** (Network Security Group, le pare-feu d'Azure) : HTTPS autorisé, SSH refusé.
Les règles viendront d'une variable : en ajouter une ne demandera aucune nouvelle ressource dans le code.

> **Avant de commencer** : dans `jour1/`, lancez `terraform state list`. La liste doit montrer les ressources du TP précédent.
> Liste vide ? Vous n'êtes pas dans le bon dossier : revenez dans `jour1/` (`cd` depuis la racine du dépôt).

### Étape 1 : les règles dans une variable

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

> **Explication.**
> - `map(object({...}))` : une map dont chaque valeur est un objet aux champs typés. La clé (`allow-https`, `deny-ssh`) servira de nom à la règle.
> - `priority` : de 100 à 4096. La règle à la plus petite priorité est évaluée en premier.

### Étape 2 : le NSG

**À compléter** dans un nouveau fichier `nsg.tf` :

```hcl
resource "azurerm_network_security_group" "app" {
  name                = "nsg-${local.name_prefix}-app"
  location            = ...                 # À COMPLÉTER : la région du resource group (référence)
  resource_group_name = ...                 # À COMPLÉTER : le nom du resource group (référence)
}
```

### Étape 3 : toutes les règles avec une seule ressource

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

> **Explication.**
> - `each.key` : la clé de l'élément courant (`allow-https`). `each.value` : sa valeur, l'objet ; `each.value.priority` en lit un champ.
> - `name` : le nom de la règle dans Azure, ici la clé de la map (`allow-https`, `deny-ssh`).
> - `priority` : de 100 à 4096. Azure lit les règles de la plus petite à la plus grande et **s'arrête à la première qui correspond**. Deux règles d'un même NSG ne peuvent pas avoir la même priorité.
> - `direction` : `"Inbound"` filtre le trafic **entrant** dans le sous-réseau, `"Outbound"` le trafic sortant.
> - `access` : `"Allow"` laisse passer, `"Deny"` bloque.
> - `protocol` : `"Tcp"`, `"Udp"`, `"Icmp"` (le ping) ou `"*"` pour tous. HTTPS et SSH utilisent TCP.
> - `source_port_range` : le port **de départ**, côté client. Il est choisi au hasard par la machine qui se connecte : on met presque toujours `"*"`.
> - `destination_port_range` : le port **d'arrivée**, celui du service visé (`443` pour HTTPS, `22` pour SSH). Une plage s'écrit `"8000-8080"`.
> - `source_address_prefix` : d'où vient le trafic. `"*"` : de partout. On peut mettre une adresse (`"203.0.113.10"`), une plage CIDR (`"10.0.0.0/16"`) ou un nom fourni par Azure (`"Internet"`, `"VirtualNetwork"`).
> - `destination_address_prefix` : où va le trafic, avec les mêmes valeurs possibles. `"*"` : tout ce que protège le NSG.
> - `resource_group_name` et `network_security_group_name` : à quel NSG la règle appartient. La règle est une ressource à part, rattachée au NSG par son nom : c'est ce qui permet de la créer avec `for_each`.
> - `"*"` : partout où il apparaît, il signifie « n'importe quelle valeur ».

### Étape 4 : associer le NSG au sous-réseau

Un NSG ne filtre rien tant qu'il n'est pas associé à un sous-réseau.

**À écrire** à la suite, dans `nsg.tf` : une ressource `azurerm_subnet_network_security_group_association` nommée `app`, avec deux arguments :
- `subnet_id` : l'id de `snet-app` ;
- `network_security_group_id` : l'id du NSG de l'étape 2.

### Étape 5 : un second NSG, seulement si on le demande

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

> **Explication.**
> - `condition ? a : b` vaut `a` si la condition est vraie, sinon `b`.
> - Avec `count`, la ressource devient une **liste** : `[0]` désigne sa première (et seule) instance.

### Étape 6 : comparer les plans

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

### Étape 7 : retrouver le NSG dans le portail

1. Dans `rg-<prénom>-dev`, ouvrez `nsg-<prénom>-dev-app`.
2. Menu **Settings > Inbound security rules** (Paramètres > Règles de sécurité de trafic entrant) : vos règles `allow-https` (100) et `deny-ssh` (200), au-dessus des règles par défaut d'Azure (65000 et plus).
3. Menu **Settings > Subnets** (Paramètres > Sous-réseaux) : le NSG est associé à `snet-app`.
4. Côté VNet, **Subnets** (Sous-réseaux) : la colonne **Security group** (Groupe de sécurité) indique `nsg-<prénom>-dev-app` pour `snet-app`, rien pour `snet-data`.

### Documentation

- [`azurerm_network_security_group`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)
- [`azurerm_network_security_rule`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule)
- [`azurerm_subnet_network_security_group_association`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association)
- [`for_each`](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each)
- [`count`](https://developer.hashicorp.com/terraform/language/meta-arguments/count)

### Questions

- Comment s'appelle chaque règle dans le state (`terraform state list`) ?
- Pourquoi `for_each` plutôt que `count` pour les règles ?

### Pour aller plus loin

1. Protégez le NSG de `snet-app` contre la destruction.

   **À copier** dans le bloc `azurerm_network_security_group` `app` :

   ```hcl
     lifecycle {
       prevent_destroy = true
     }
   ```

2. Essayez de tout détruire.

   **À lancer** :

   ```bash
   # Tente de supprimer toutes les ressources du dossier
   terraform destroy -var-file=dev.tfvars
   ```

3. Lisez la réponse de Terraform : que se passe-t-il ? Une ressource a-t-elle été supprimée ?

4. Retirez le bloc `lifecycle` : le TP5 en a besoin.

</details>

## TP5 : module réseau

<details>
<summary><b>Afficher l'énoncé du TP5</b></summary>

**Objectif** : ranger le réseau dans un module, puis l'appeler deux fois. **Durée** : 50 minutes.
**Dossier de travail** : `jour1/`

### Où on en est, où on va

Votre `rg-<prénom>-dev` contient un VNet, deux sous-réseaux et un NSG, décrits dans `network.tf` et `nsg.tf`.
À la fin de ce TP, ce réseau sera un **module** : un dossier de code réutilisable. Vous l'appellerez deux fois pour obtenir deux réseaux, `dev` et `prod`, dans un nouveau resource group `rg-<prénom>-reseau`.

C'est le TP le plus autonome de la journée : beaucoup d'étapes sont à écrire.

> **Avant de commencer** : dans `jour1/`, lancez `terraform state list`. La liste doit montrer les ressources du TP précédent.
> Liste vide ? Vous n'êtes pas dans le bon dossier : revenez dans `jour1/` (`cd` depuis la racine du dépôt).

### Étape 1 : créer le dossier du module

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
jour1/
├── enonce.md   README.md   solutions/   (le dépôt)
├── versions.tf   variables.tf   main.tf   outputs.tf   dev.tfvars
├── network.tf    nsg.tf                  (à vider à l'étape 3)
└── modules/
    └── network/
        ├── main.tf        le réseau : VNet, sous-réseaux, NSG
        ├── variables.tf   ses entrées
        └── outputs.tf     ce qu'il renvoie
```

### Étape 2 : les entrées du module

Dans un module, `var.x` désigne une entrée **du module**, donnée par celui qui l'appelle.

**À copier** dans `modules/network/variables.tf` :

```hcl
variable "prefix" {
  type        = string
  description = "Préfixe des noms de ressources (dev, prod)"
}

variable "subnets" {
  type        = map(string)
  description = "Nom court du sous-réseau vers son CIDR"
}
```

**À écrire** dans le même fichier :
- `resource_group_name` et `location`, de type `string` ;
- `address_space`, de type `list(string)` ;
- `nsg_rules` : **coupez** la variable `nsg_rules` de votre `variables.tf` (à la racine) et collez-la ici, avec son `default`.

> **Explication.** Le module ne déclare ni bloc `terraform { }` ni `provider` : il utilise ceux du module racine.

### Étape 3 : déplacer le réseau dans le module

1. **Coupez** tout le contenu de `network.tf` et de `nsg.tf` (à la racine), et collez-le dans `modules/network/main.tf`. Supprimez ensuite les deux fichiers vides.
2. **Supprimez** de `modules/network/main.tf` le NSG `data` et son association (le module reste simple), et la variable `enable_data_nsg` de votre `variables.tf`.
3. **Remplacez**, dans tout `modules/network/main.tf` :

| Avant | Après |
|---|---|
| `azurerm_resource_group.main.name` | `var.resource_group_name` |
| `azurerm_resource_group.main.location` | `var.location` |
| `"vnet-${local.name_prefix}"` | `"vnet-${var.prefix}"` |
| `"nsg-${local.name_prefix}-app"` | `"nsg-${var.prefix}"` (un NSG pour tout le réseau) |
| `resource "azurerm_virtual_network" "main"` | `resource "azurerm_virtual_network" "this"` (et ses références) |
| `"app"` dans les noms Terraform du NSG, des règles et de l'association | `"this"` (et leurs références) |

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

5. **Remplacez** l'association par une association **par sous-réseau** : le même NSG protège tous les sous-réseaux du réseau.

**À compléter** :

```hcl
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = ...                                                # À COMPLÉTER : la variable des sous-réseaux

  subnet_id                 = azurerm_subnet.this[...].id       # À COMPLÉTER : la clé de l'élément courant
  network_security_group_id = azurerm_network_security_group.this.id
}
```

> **Explication.**
> - `"this"` : le nom d'usage quand un module ne contient qu'une ressource de ce type.
> - Avec `for_each`, `azurerm_subnet.this` est une collection : `[each.key]` choisit le sous-réseau qui porte la même clé que l'association.
> - Le module ne connaît plus aucun nom de sous-réseau : ajouter un sous-réseau dans l'appel le crée **et** le protège.

### Étape 4 : les sorties du module

**À compléter** dans `modules/network/outputs.tf` :

```hcl
output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "subnet_ids" {
  value = { for name, subnet in azurerm_subnet.this : name => ... }   # À COMPLÉTER : l'id du sous-réseau
}
```

> **Explication.** `{ for k, v in collection : k => valeur }` construit une map : ici, le nom de chaque sous-réseau vers son id.

### Étape 5 : alléger la racine

Le réseau a quitté la racine : ce qui le concernait n'y sert plus.

**À faire** :
1. `variables.tf` (racine) : ne gardez que `prenom` et `location`. Supprimez `environment` et `address_space` (`nsg_rules` et `enable_data_nsg` sont déjà partis).
2. `main.tf` : supprimez le bloc `locals`, et nommez le resource group `"rg-${var.prenom}-reseau"`.
3. `dev.tfvars` : ne gardez que la ligne `prenom`.

### Étape 6 : appeler le module deux fois

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

> **Explication.** `module "nom"` appelle un module. `source` dit où il se trouve (ici un dossier local) ; les autres arguments remplissent ses variables.

### Étape 7 : les sorties de la racine

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

> **Explication.** `module.network_dev.vnet_id` lit un output du module : c'est la seule façon de récupérer une valeur de l'intérieur d'un module.

### Étape 8 : initialiser, planifier, appliquer

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

**Vérifier** : le plan annonce `17 to add` et `8 to destroy`. Les 8 destructions sont l'ancien réseau du TP4 (le resource group `-dev` et son contenu) : c'est normal, et la question ci-dessous y revient.

### Étape 9 : retrouver les deux réseaux dans le portail

1. Ouvrez `rg-<prénom>-reseau` : **Overview** (Vue d'ensemble) liste `vnet-dev`, `vnet-prod`, `nsg-dev` et `nsg-prod`.
2. Ouvrez `vnet-prod`, menu **Settings > Subnets** (Paramètres > Sous-réseaux) : `snet-app` (`10.20.1.0/24`) et `snet-data` (`10.20.2.0/24`), tous deux protégés par `nsg-prod`.
3. Faites de même avec `vnet-dev` : même structure, autres plages. C'est le même module.
4. Vérifiez que `rg-<prénom>-dev` a disparu.

### Documentation

- [Les modules](https://developer.hashicorp.com/terraform/language/modules)
- [L'expression `for`](https://developer.hashicorp.com/terraform/language/expressions/for)
- [`cidrsubnet`](https://developer.hashicorp.com/terraform/language/functions/cidrsubnet)

### Questions

- Combien de ressources contient chaque appel du module ?
- Pourquoi `init` est-il nécessaire après l'ajout d'un module ?
- Le plan détruisait votre ancien réseau. Comment l'éviter ? (Réponse demain, avec le bloc `moved`.)

### Pour aller plus loin

**À écrire** : supprimez la variable `subnets` et calculez les CIDR dans le module. `cidrsubnet(var.address_space[0], 8, 1)` donne le premier `/24` du `/16`, `cidrsubnet(var.address_space[0], 8, 2)` le deuxième.

</details>

## Bonus : une VM configurée par cloud-init

<details>
<summary><b>Afficher l'énoncé du bonus</b></summary>

**Objectif** : déployer une machine virtuelle dont la configuration est générée par `templatefile`. **Durée** : 30 minutes.
**Dossier de travail** : `jour1/bonus/`

### Où on en est, où on va

Ce bonus est **autonome** : il ne touche pas au réseau du fil rouge. Vous créez un resource group `rg-<prénom>-vm`, un petit réseau, puis une VM Linux qui installe un serveur web toute seule à son premier démarrage.

La VM consomme 2 vCPU du quota partagé : **détruisez-la à la fin**.

### Étape 1 : un dossier à part

Ce code a son propre state : il ne doit pas se mélanger à celui du fil rouge.

**À lancer** :

```bash
# Depuis jour1/ : le dossier du bonus, avec son propre state
cd bonus
# Reprend vos variables et vos valeurs du fil rouge
cp ../variables.tf ../dev.tfvars .
```

Dans ces deux copies, gardez seulement `prenom` et `location` (`variables.tf`) et la ligne `prenom` (`dev.tfvars`).

### Étape 2 : les providers

`tls` est un provider qui fabrique des clés et des certificats, sans appeler aucun cloud.

**À copier** dans `versions.tf` :

```hcl
terraform {
  required_version = ">= 1.15.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

### Étape 3 : le resource group et le réseau

**À écrire** dans `main.tf`, en reprenant le code du TP3 :
- un resource group `"rg-${var.prenom}-vm"` ;
- un VNet `"vnet-${var.prenom}-vm"` en `10.0.0.0/16` (`address_space = ["10.0.0.0/16"]`, sans variable) ;
- un sous-réseau `app` nommé `snet-app`, en `10.0.1.0/24`.

### Étape 4 : une carte réseau sans IP publique

**À compléter** à la suite :

```hcl
resource "azurerm_network_interface" "vm" {
  name                = "nic-${var.prenom}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "interne"
    subnet_id                     = ...          # À COMPLÉTER : l'id du sous-réseau de l'étape 3
    private_ip_address_allocation = "Dynamic"
  }
}
```

> **Explication.** `ip_configuration` est un **bloc imbriqué** : il relie la carte au sous-réseau. `"Dynamic"` : Azure choisit l'adresse privée.

### Étape 5 : une clé SSH

**À copier** à la suite :

```hcl
resource "tls_private_key" "vm" {
  algorithm = "ED25519"
}
```

> **Explication.** La clé est générée par Terraform et stockée **en clair dans le state** : acceptable pour un TP, pas en production.

### Étape 6 : le script de démarrage

`cloud-init` est le standard qui configure une VM Linux à son premier démarrage.

**À copier** dans un nouveau fichier `cloud-init.tftpl` :

```yaml
#cloud-config
hostname: ${hostname}
package_update: true
packages:
  - nginx
write_files:
  - path: /var/www/html/index.html
    content: |
      <h1>Bonjour ${prenom}</h1>
      <p>Cette page a été écrite par cloud-init sur ${hostname}.</p>
```

**À compléter** en haut de `main.tf` :

```hcl
locals {
  cloud_init = templatefile("${path.module}/cloud-init.tftpl", {
    hostname = "vm-${var.prenom}"
    prenom   = ...                 # À COMPLÉTER : la variable prenom
  })
}
```

> **Explication.** `templatefile(fichier, valeurs)` lit le fichier et remplace chaque `${...}` par la valeur donnée. `path.module` : le dossier du code courant.

### Étape 7 : la VM

**À compléter** à la fin de `main.tf` :

```hcl
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "vm-${var.prenom}"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  size                  = "..."                          # À COMPLÉTER : la seule taille autorisée, Standard_D2as_v6
  admin_username        = "azureuser"
  network_interface_ids = [...]                          # À COMPLÉTER : l'id de la carte réseau, dans une liste
  custom_data           = base64encode(local.cloud_init)
  disk_controller_type  = "NVMe"

  admin_ssh_key {
    username   = "azureuser"
    public_key = ...                                     # À COMPLÉTER : l'attribut public_key_openssh de la clé
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}
```

> **Explication.**
> - Pas d'argument `zone` : la création ne dépend pas de la capacité d'une zone précise.
> - `custom_data` : le script passé à la VM, encodé en base64.
> - `disk_controller_type = "NVMe"` : obligatoire, cette taille n'accepte que des disques NVMe.
> - `admin_ssh_key` : la clé publique autorisée à se connecter. Aucun mot de passe.
> - `source_image_reference` : l'image du système, ici Ubuntu 24.04.

### Étape 8 : les sorties, puis le déploiement

**À écrire** dans `outputs.tf` : un output `private_ip` avec l'adresse privée de la carte réseau (attribut `private_ip_address`).

**À copier** à la suite :

```hcl
output "ssh_private_key" {
  value     = tls_private_key.vm.private_key_openssh
  sensitive = true
}
```

**À lancer** :

```bash
# Télécharge azurerm et tls
terraform init
terraform plan -var-file=dev.tfvars
# Crée la VM : 2 à 3 minutes (tapez yes)
terraform apply -var-file=dev.tfvars
```

**Vérifier** : le plan annonce `6 to add`.

### Étape 9 : retrouver la VM dans le portail

1. Ouvrez `rg-<prénom>-vm` : la VM, sa carte réseau, son disque (`vm-<prénom>_OsDisk_...`), le VNet. Azure a créé le disque pour vous.
2. Ouvrez `vm-<prénom>` : **Overview** (Vue d'ensemble) affiche la taille `Standard_D2as_v6` et l'adresse IP privée. Comparez avec `terraform output private_ip`.
3. Menu **Operations > Run command** (Opérations > Exécuter la commande), choisissez **RunShellScript**, tapez `curl -s localhost` et lancez.
   Après une à deux minutes, la sortie affiche votre page : cloud-init a installé nginx.

### Étape 10 : détruire

La VM coûte tant qu'elle existe.

**À lancer** :

```bash
# Supprime la VM et tout le reste de ce dossier (tapez yes)
terraform destroy -var-file=dev.tfvars
```

### Documentation

- [`azurerm_network_interface`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface)
- [`azurerm_linux_virtual_machine`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine)
- [`tls_private_key`](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key)
- [`templatefile`](https://developer.hashicorp.com/terraform/language/functions/templatefile)

### Pour aller plus loin

Ajoutez une IP publique et une règle NSG qui autorise SSH depuis votre seule adresse IP, connectez-vous
(`terraform output -raw ssh_private_key > cle && chmod 600 cle`, puis `ssh -i cle azureuser@<ip>`), puis retirez l'IP publique.
Sous Windows, faites cette étape dans Git Bash : PowerShell n'applique pas `chmod`.

</details>
