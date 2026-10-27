# Jour 3 : énoncé

## Table des matières

| Partie | Sujet | Dossier | Durée |
|---|---|---|---|
| [Prérequis](#lire-les-énoncés) | Lire les énoncés, se connecter à Azure |  | 5 min |
| [TP1](#tp1--écrire-le-socle-et-brancher-terraform-sur-le-cluster) | Écrire le socle et brancher Terraform sur le cluster | `jour3/socle/`, `jour3/app/` | 50 min |
| [TP2](#tp2--mon-application-en-ligne) | Mon application en ligne | `jour3/app/` | 30 min |
| [TP3](#tp3--exploiter-le-cluster-et-lapplication) | Exploiter le cluster et l'application | `jour3/socle/`, `jour3/app/` | 45 min |
| [Bonus](#bonus--monter-de-version-kubernetes) | Monter de version Kubernetes | `jour3/socle/` | 35 min |

Le jour 3 ne dépend pas de vos TP d'hier : le socle s'écrit à partir de specs, le reste du code est fourni.

| Dossier | Contenu |
|---|---|
| `jour3/socle/` | Le socle à écrire au TP1 : réseau, identité et cluster AKS en Kubernetes 1.35. Les variables et les outputs sont fournis |
| `jour3/app/` | Le point de départ de l'application, avec le module `modules/microservices` déjà écrit |

Vous travaillez **directement dans ces dossiers** du dépôt cloné. Chaque TP indique le sien.
Les solutions arrivent dans `jour3/solutions/tpN/` après chaque correction (`git pull`).

## Lire les énoncés

Les mêmes repères qu'aux jours 1 et 2 :

| Repère | Ce que vous faites |
|---|---|
| **À copier** | Recopiez le bloc tel quel dans le fichier indiqué. |
| **À compléter** | Recopiez le bloc, puis remplacez chaque `...` : le commentaire `# À COMPLÉTER : ...` dit quoi mettre. |
| **À écrire** | Écrivez le bloc vous-même, à partir de la consigne. |
| **À lancer** | Tapez les commandes dans le terminal, dans le dossier de travail du TP. La ligne `#` au-dessus dit ce que fait chaque commande. |
| **Vérifier** | Ce que vous devez obtenir. Sinon, arrêtez-vous et demandez. |

> **Explication.** Ces citations expliquent le code : à lire, rien à faire.

Tout ce qui est entre chevrons `< >` est à remplacer, chevrons compris : `aks-<prénom>` devient `aks-alexandre`.

## Avant de commencer

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

## Cliquer pour naviguer vers un TP

| TP | Sujet | Dossier | Durée |
|---|---|---|---|
| [TP1](#tp1--écrire-le-socle-et-brancher-terraform-sur-le-cluster) | Écrire le socle et brancher Terraform sur le cluster | `jour3/socle/`, `jour3/app/` | 50 min |
| [TP2](#tp2--mon-application-en-ligne) | Mon application en ligne | `jour3/app/` | 30 min |
| [TP3](#tp3--exploiter-le-cluster-et-lapplication) | Exploiter le cluster et l'application | `jour3/socle/`, `jour3/app/` | 45 min |
| [Bonus](#bonus--monter-de-version-kubernetes) | Monter de version Kubernetes | `jour3/socle/` | 35 min |

## Avant de partir

Détruisez dans l'ordre inverse de la création. **À lancer**, depuis `jour3/` :

```bash
# D'abord l'application, puis le cluster
cd app && terraform destroy -var-file=dev.tfvars && cd ..
cd socle && terraform destroy -var-file=dev.tfvars && cd ..
# Il ne doit plus rien rester à votre nom
az group list --query "[?starts_with(name, 'rg-<prénom>')].name" -o table
```

## TP1 : écrire le socle et brancher Terraform sur le cluster

<details>
<summary><b>Afficher l'énoncé du TP1</b></summary>

**Objectif** : écrire le réseau, l'identité et le cluster AKS, puis configurer le provider `kubernetes` et créer un premier objet dans le cluster. **Durée** : 50 minutes.
**Dossier de travail** : `jour3/socle/`, puis `jour3/app/`

### Où on en est, où on va

Le cluster d'hier a été détruit pour ne pas payer la nuit. Vous écrivez le **socle** : un réseau, une identité et un cluster, en Kubernetes 1.35, une version en arrière pour pratiquer la montée de version en bonus. Le réseau et l'identité, vous les avez déjà écrits : ici, seules les specs sont données.
Ensuite, Terraform parlera aussi à l'API du cluster, et vous y créerez un premier objet : le namespace `app`, qui accueillera l'application au TP2.

> **Règle du temps** : la création du cluster prend 5 à 10 minutes. Lancez l'`apply` de l'**étape 5** au plus tard 25 minutes après le début du TP. Vous écrirez les étapes 6 et 7 pendant l'attente.

### Étape 1 : votre prénom

**À compléter**, dans **chacun** des deux fichiers `socle/dev.tfvars` et `app/dev.tfvars` :

```hcl
prenom = "<prénom>"   # À COMPLÉTER : votre prénom, par exemple "alexandre"
```

> **Explication.** Le dossier `socle/` contient déjà `versions.tf`, `variables.tf` (`prenom`, `location`, `kubernetes_version`) et `outputs.tf`. Les outputs utilisent les noms `main` du resource group et du cluster : gardez exactement les noms du code donnés ci-dessous.

### Étape 2 : le réseau

**Fichier** : `network.tf`, dans `jour3/socle/`.

| Ressource | Nom dans le code | Specs |
|---|---|---|
| `azurerm_resource_group` | `main` | Nom `rg-<prénom>-j3`, région `var.location` |
| `azurerm_virtual_network` | `main` | Nom `vnet-<prénom>-j3`, espace d'adresses `10.42.0.0/16`, dans le resource group ci-dessus |
| `azurerm_subnet` | `aks` | Nom `snet-aks`, plage `10.42.1.0/24`, dans le VNet ci-dessus |

> **Explication.** Le sous-réseau n'accueille que les **nœuds** : les pods prennent leurs adresses dans un réseau à part, propre au cluster (le mode *overlay*, à l'étape 4). Un `/24` suffit donc largement.

<details>
<summary>Syntaxe : le réseau du jour 1 (à ouvrir en cas d’oubli ou de blocage)</summary>

```hcl
resource "azurerm_virtual_network" "<nom>" {
  name                = "<nom du VNet>"
  location            = <référence à la région du resource group>
  resource_group_name = <référence au nom du resource group>
  address_space       = ["<plage CIDR>"]
}

resource "azurerm_subnet" "<nom>" {
  name                 = "<nom du sous-réseau>"
  resource_group_name  = <référence au nom du resource group>
  virtual_network_name = <référence au nom du VNet>
  address_prefixes     = ["<plage CIDR>"]
}
```

</details>

### Étape 3 : l'identité du cluster

**Fichier** : `identity.tf`, dans `jour3/socle/`.

| Ressource | Nom dans le code | Specs |
|---|---|---|
| `azurerm_user_assigned_identity` | `aks` | Nom `id-<prénom>-aks`, dans le resource group de l'étape 2 |
| `azurerm_role_assignment` | `aks_subnet` | Rôle `Network Contributor`, sur le **sous-réseau** `snet-aks`, donné à l'identité ci-dessus |

> **Explication.** Le cluster va brancher ses nœuds et son load balancer sur **votre** sous-réseau : son identité doit en avoir le droit **avant** sa création. Une identité attribuée par l'utilisateur existe avant le cluster : on lui donne son rôle d'abord. C'est le même trio qu'au TP3 d'hier : qui (l'identité), quoi (le rôle), où (le scope).

<details>
<summary>Syntaxe : une identité et son rôle, comme au TP3 du jour 2 (à ouvrir en cas d’oubli ou de blocage)</summary>

```hcl
resource "azurerm_user_assigned_identity" "<nom>" {
  name                = "<nom de l'identité>"
  location            = <référence à la région du resource group>
  resource_group_name = <référence au nom du resource group>
}

resource "azurerm_role_assignment" "<nom>" {
  scope                = <référence à l'id de la ressource visée>
  role_definition_name = "<nom du rôle>"
  principal_id         = <référence au principal_id de l'identité>
}
```

</details>

### Étape 4 : le cluster

**À compléter** dans un nouveau fichier `aks.tf`, dans `jour3/socle/` :

```hcl
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.prenom}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${var.prenom}"
  kubernetes_version  = var.kubernetes_version

  # Un seul nœud, sans zone : la création ne dépend pas de la capacité d'une zone précise.
  default_node_pool {
    name                        = "system"
    vm_size                     = "..."                  # À COMPLÉTER : Standard_D2as_v6
    node_count                  = 1
    orchestrator_version        = var.kubernetes_version # les nœuds suivent la version du cluster
    vnet_subnet_id              = ...                    # À COMPLÉTER : l'id du sous-réseau de l'étape 2
    temporary_name_for_rotation = "systemtmp"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [...]                                 # À COMPLÉTER : l'id de l'identité de l'étape 3
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
  }

  node_provisioning_profile {
    mode = "Manual"
  }

  depends_on = [...]                                     # À COMPLÉTER : l'attribution de rôle de l'étape 3
}
```

> **Explication.**
> - `vnet_subnet_id` : les nœuds se branchent sur **votre** sous-réseau, au lieu d'un VNet créé par AKS comme au TP5 d'hier.
> - `identity` en `UserAssigned` : le cluster utilise l'identité de l'étape 3, déjà munie de son rôle.
> - `depends_on` : rien dans le cluster ne référence l'attribution de rôle. Sans cette ligne, Terraform pourrait créer le cluster avant que le rôle existe.
> - `network_plugin_mode = "overlay"` : les pods ont leurs adresses dans un réseau propre au cluster, pas dans le VNet.
> - `node_provisioning_profile` : `Manual`, c'est nous qui décrivons les pools de nœuds. Obligatoire avec azurerm 5.

### Étape 5 : créer le socle

**À lancer**, depuis la racine du dépôt cloné :

```bash
cd jour3/socle
terraform init
terraform validate
# Lisez le plan (6 to add), tapez yes : la création démarre, 5 à 10 minutes
terraform apply -var-file=dev.tfvars
```

**Laissez ce terminal tourner** et passez à l'étape 6 dans un second terminal.

### Étape 6 : pendant l'attente, le provider kubernetes

**À compléter** dans un nouveau fichier `providers.tf`, dans `jour3/app/` :

```hcl
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = coalesce(var.kube_context, "aks-${...}")   # À COMPLÉTER : la variable du prénom
}
```

> **Explication.**
> - Le dossier `app/` contient déjà `versions.tf` (providers `azurerm` et `kubernetes`), `variables.tf` (`prenom` et `kube_context`), `dev.tfvars`, et le module `modules/microservices` que vous appellerez au TP2.
> - `config_path` : le fichier écrit par `az aks get-credentials`. Le provider s'y connecte comme `kubectl`.
> - `coalesce(a, b)` renvoie la première valeur non vide : `kube_context` si vous l'avez donné, sinon `aks-<prénom>`.

### Étape 7 : pendant l'attente, le namespace

Un **namespace** est un espace de noms dans le cluster : il range les objets d'une même application.

**À compléter** dans un nouveau fichier `namespace.tf`, dans `jour3/app/` :

```hcl
resource "kubernetes_namespace_v1" "app" {
  metadata {
    name   = "..."                    # À COMPLÉTER : app
    labels = { owner = ... }          # À COMPLÉTER : la variable du prénom
  }
}
```

> **Explication.** Les ressources du provider kubernetes 3 finissent par `_v1` : c'est la version de l'API Kubernetes qu'elles utilisent.

### Étape 8 : se connecter au cluster

**À lancer**, dans `jour3/socle/`, quand l'`apply` de l'étape 5 est **terminé** :

```bash
# Affiche la commande qui écrit les accès du cluster dans ~/.kube/config
terraform output -raw get_credentials
# Copiez-collez la commande affichée, puis :
kubectl get nodes
# Le contexte courant doit être celui de VOTRE cluster
kubectl config current-context
```

**Vérifier** : un nœud `Ready`, et le contexte `aks-<prénom>`.

> **Explication.** Un **contexte** kubectl désigne un cluster et un utilisateur. Plusieurs clusters dans `~/.kube/config` : se tromper de contexte, c'est déployer sur le cluster de quelqu'un d'autre.

### Étape 9 : créer le namespace

**À lancer** :

```bash
cd ../app
terraform init
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
# Liste les namespaces du cluster : app doit y être
kubectl get ns
```

**Vérifier** : le plan annonce `1 to add`, et `kubectl get ns` montre `app`.

### Étape 10 : lire le module fourni

**À faire** : ouvrez `modules/microservices/variables.tf`. Quelles variables le module attend-il ? Lesquelles ont une valeur par défaut ? Vous l'appellerez au TP2.

### Étape 11 : retrouver le socle et le namespace dans le portail

1. Ouvrez `rg-<prénom>-j3` : le VNet, l'identité `id-<prénom>-aks` et le cluster `aks-<prénom>`.
2. Sur le sous-réseau `snet-aks`, menu **Access control (IAM)** (Contrôle d'accès) : l'identité a le rôle `Network Contributor`.
3. Ouvrez le cluster, menu **Kubernetes resources > Namespaces** (Ressources Kubernetes > Espaces de noms) : `app` y figure, avec le label `owner`.

### Documentation

- [`azurerm_kubernetes_cluster`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)
- [Le provider kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [`kubernetes_namespace_v1`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1)

### Questions

- Pourquoi l'identité du cluster est-elle créée avant lui, et pas avec lui comme au TP5 d'hier ?
- Que se passe-t-il si `config_context` désigne le cluster d'un autre participant ?
- Pourquoi déclarer le provider à la racine et pas dans le module ?

### Pour aller plus loin

**À lancer** : `terraform state list`, dans `socle/` puis dans `app/`. Quelles ressources chaque configuration connaît-elle ?

</details>

## TP2 : mon application en ligne

<details>
<summary><b>Afficher l'énoncé du TP2</b></summary>

**Objectif** : voir votre application tourner sur Internet, avec une adresse fournie par Azure. **Durée** : 30 minutes.
**Dossier de travail** : `jour3/app/`

### Où on en est, où on va

Le namespace `app` existe. Les images de l'application (un frontend, un service A, un service B) sont dans le registre partagé `acrformationtf`.
À la fin de ce TP, l'application tournera dans votre cluster et sera visible sur Internet, à une adresse IP créée par Azure. Le service B garde un compteur de visites sur un disque qui survit aux pods.

### Étape 1 : lire le registre partagé

**À écrire** dans un nouveau fichier `main.tf`, deux data sources, dans cet ordre :

1. `data "azurerm_resource_group" "shared"` : lit le resource group `rg-formation-partage`.
2. `data "azurerm_container_registry" "acr"` : lit le registre `acrformationtf`, dans ce resource group, **par référence** au data source précédent.

> **Explication.** La même chaîne de références que pour des ressources : le resource group, puis le registre, puis le module de l'étape 2. Terraform lit chaque data source après ceux dont il dépend, et le nom du resource group n'est écrit qu'une fois.

### Étape 2 : appeler le module

Le module `modules/microservices` contient les trois déploiements, le disque et les services internes. Vous l'appelez avec quelques valeurs.

**À compléter** à la suite, dans `main.tf` :

```hcl
module "microservices" {
  source    = "./modules/microservices"
  namespace = kubernetes_namespace_v1.app.metadata[0].name
  prenom    = var.prenom
  registry  = ...              # À COMPLÉTER : l'attribut login_server du registre de l'étape 1
  tag       = "..."            # À COMPLÉTER : v1
  replicas  = ...              # À COMPLÉTER : 2
}
```

> **Explication.**
> - `kubernetes_namespace_v1.app.metadata[0].name` : le nom du namespace du TP1. La référence garantit qu'il existe avant l'application.
> - `registry` vaut `acrformationtf.azurecr.io` : les images s'y tirent sans authentification.

### Étape 3 : exposer le frontend sur Internet

Un Service de type `LoadBalancer` demande à Azure une IP publique, et dirige le trafic vers les pods du frontend. C'est le seul composant exposé.

**À compléter** dans un nouveau fichier `modules/microservices/frontend-service.tf` (dans le **module**) :

```hcl
resource "kubernetes_service_v1" "frontend" {
  metadata {
    name      = "frontend"
    namespace = var.namespace
    annotations = var.dns_label_enabled ? {
      "service.beta.kubernetes.io/azure-dns-label-name" = "tf-${var.prenom}"
    } : {}
  }

  spec {
    type     = "..."                 # À COMPLÉTER : LoadBalancer
    selector = { app = "..." }       # À COMPLÉTER : le label des pods du frontend, frontend

    port {
      port        = ...              # À COMPLÉTER : 80, le port exposé sur Internet
      target_port = ...              # À COMPLÉTER : 8080, le port du conteneur
    }
  }
}
```

> **Explication.**
> - `selector` relie le Service aux pods qui portent ce label : c'est ainsi qu'il sait où envoyer le trafic.
> - `port` est le port exposé, `target_port` celui sur lequel écoute le conteneur.
> - `annotations` : un nom DNS optionnel (voir « Pour aller plus loin »). Vide par défaut.

### Étape 4 : récupérer l'adresse

L'IP est attribuée par Azure **après** la création : elle se lit dans le statut du Service.

**À copier** à la fin de `modules/microservices/outputs.tf` :

```hcl
locals {
  lb = kubernetes_service_v1.frontend.status[0]
}

output "url" {
  value = "http://${local.lb.load_balancer[0].ingress[0].ip}"
}
```

> **Explication.** `status[0].load_balancer[0].ingress[0].ip` descend dans le statut du Service : le premier point d'entrée du load balancer, puis son adresse IP.

**À écrire** dans un nouveau fichier `outputs.tf` (à la racine de `app/`) : un output `app_url` qui affiche `module.microservices.url`.

### Étape 5 : déployer

**À lancer** :

```bash
# Nouveau module : init est obligatoire
terraform init
terraform plan -var-file=dev.tfvars
# L'attente de l'IP publique prend une à deux minutes
terraform apply -var-file=dev.tfvars
```

**Vérifier** : le plan annonce `7 to add` (trois déploiements, le disque, trois services), puis l'output `app_url` affiche une adresse `http://...`.

### Étape 6 : voir l'application vivre

1. Ouvrez l'URL dans le navigateur, puis actualisez plusieurs fois : le nom du pod du service A change. Deux réplicas se partagent les requêtes.
2. **À lancer** :

```bash
# Supprime le pod du service B : Kubernetes en recrée un aussitôt
kubectl delete pod -n app -l app=service-b
# Regardez le nouveau pod démarrer
kubectl get pods -n app
```

3. Actualisez la page : le compteur de visites a **survécu**, grâce au volume persistant.

### Étape 7 : retrouver l'application dans le portail

1. Dans `aks-<prénom>`, menu **Kubernetes resources > Workloads** (Charges de travail) : les déploiements `frontend`, `service-a` et `service-b` dans `app`.
2. Menu **Services and ingresses** (Services et entrées) : `frontend`, de type `LoadBalancer`, avec son IP externe.
3. Ouvrez le resource group `MC_rg-<prénom>-j3_aks-<prénom>_swedencentral` : l'IP publique et le disque du compteur ont été créés par AKS.

### Documentation

- [`kubernetes_service_v1`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1)
- [`kubernetes_deployment_v1`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1)

### Questions

- Pourquoi le service B n'a-t-il qu'un réplica ?
- Quel objet Azure a été créé pour votre Service `LoadBalancer` ? Où est-il ?

### Pour aller plus loin

**À compléter** dans l'appel du module : ajoutez `dns_label_enabled = true`.

**À écrire** dans `outputs.tf`, à la racine de `app/` : un output `app_dns_url` qui affiche `module.microservices.dns_url`. Puis `apply`.

**Vérifier** : l'output `app_dns_url` affiche `http://tf-<prénom>.swedencentral.cloudapp.azure.com`. Ouvrez-la : un nom fourni par Azure, sans aucune configuration DNS. Le nom peut mettre une à deux minutes à répondre.

> **Explication.** L'output `dns_url` du module vaut `null` tant que `dns_label_enabled` est à `false` : Terraform n'affiche pas un output nul.

</details>

## TP3 : exploiter le cluster et l'application

<details>
<summary><b>Afficher l'énoncé du TP3</b></summary>

**Objectif** : faire évoluer le cluster et l'application sans les recréer : labels, autoscaler, puis une nouvelle version de l'application. **Durée** : 45 minutes.
**Dossier de travail** : `jour3/socle/`, puis `jour3/app/`

### Où on en est, où on va

Votre application tourne sur un cluster en 1.35, à un seul nœud fixe.
À la fin de ce TP, le cluster aura des tags et des labels et un autoscaler de 1 à 2 nœuds, et votre application sera passée en **v2**, sans coupure. **Lisez chaque plan avant de répondre `yes`.**

Les étapes 1 et 2 se font dans `jour3/socle/aks.tf`, dans le bloc `default_node_pool`. L'étape 3 se fait dans `jour3/app/`.

### Étape 1 : tags Azure et labels Kubernetes

**À compléter** dans `default_node_pool`, sous `temporary_name_for_rotation` :

```hcl
    tags = {
      owner = ...                # À COMPLÉTER : la variable du prénom
    }
    node_labels = {
      role = "..."               # À COMPLÉTER : system
    }
```

> **Explication.** Les **tags** sont des étiquettes Azure : facturation, inventaire. Les **labels** sont des étiquettes Kubernetes : elles servent à choisir le nœud d'un pod.

**À lancer** :

```bash
cd ../socle
# Lisez bien : modification en place (~) ou remplacement (-/+) ?
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

### Étape 2 : l'autoscaler

L'autoscaler ajoute ou retire des nœuds selon la charge, entre un minimum et un maximum.

**À faire** : dans `default_node_pool`, **supprimez** la ligne `node_count = 1`.

**À compléter** à la place :

```hcl
    auto_scaling_enabled = ...   # À COMPLÉTER : true
    min_count            = 1
    max_count            = ...   # À COMPLÉTER : 2, le maximum permis par le quota de la formation
```

**À lancer** :

```bash
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

### Étape 3 : une nouvelle version de l'application

Les images existent en deux versions, `v1` et `v2`. Passer de l'une à l'autre se fait dans le code, comme le reste.

**À modifier** dans `jour3/app/main.tf`, dans l'appel du module : `tag = "v2"`.

**À lancer**, dans deux terminaux :

```bash
# Terminal 1 : regardez les pods changer pendant l'apply (Ctrl+C pour arrêter)
kubectl get pods -n app -w
```

```bash
# Terminal 2
cd ../app
terraform apply -var-file=dev.tfvars
```

**Vérifier** :
1. Le plan annonce `3 to change` : seule l'image des trois déploiements change.
2. Dans le terminal 1, les nouveaux pods du frontend et du service A démarrent **avant** que les anciens s'arrêtent. Celui du service B s'arrête d'abord, puis repart.
3. Actualisez la page pendant l'`apply` : elle répond tout du long, et le bandeau passe au **vert** avec la pastille `v2`. Le compteur de visites a survécu.

> **Explication.**
> - Kubernetes remplace les pods progressivement (*rolling update*) : l'application reste disponible pendant la mise à jour.
> - Le service B fait exception : son disque ne se monte que sur un nœud à la fois, l'ancien pod s'arrête donc avant que le nouveau démarre (`strategy { type = "Recreate" }` dans `modules/microservices/service-b.tf`). Quelques secondes de coupure, pour lui seul.
> - Revenir en arrière, c'est remettre `tag = "v1"` et relancer `apply`.

### Étape 4 : vérifier dans le portail

1. `aks-<prénom>`, menu **Settings > Node pools** (Paramètres > Pools de nœuds) : le pool `system`, autoscaler de 1 à 2, avec le label `role=system`.
2. Le resource group `MC_rg-<prénom>-j3_aks-<prénom>_swedencentral`, le groupe de machines virtuelles des nœuds (`aks-system-...`), menu **Tags** (Étiquettes) : `owner`. Les tags du pool s'appliquent aux nœuds.
3. `aks-<prénom>`, menu **Kubernetes resources > Workloads** (Charges de travail) : l'image du déploiement `frontend` se termine par `:v2`.

### Documentation

- [`azurerm_kubernetes_cluster`, bloc `default_node_pool`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)
- [`kubernetes_deployment_v1`, bloc `strategy`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1)

### Questions

- Les tags et les labels : le plan annonçait-il `~` ou `-/+` ?
- Pourquoi la page répond-elle pendant le passage en v2, et pas le service B ?

</details>

## Bonus : monter de version Kubernetes

<details>
<summary><b>Afficher l'énoncé du bonus</b></summary>

**Objectif** : passer le cluster de Kubernetes 1.35 à 1.36, sans couper l'application. **Durée** : 35 minutes, dont 15 à 25 minutes d'attente.
**Dossier de travail** : `jour3/socle/`

### Où on en est, où on va

Votre cluster tourne en 1.35, une version mineure en retard : c'est voulu.
À la fin de ce bonus, le cluster et ses nœuds seront en 1.36, et Azure appliquera seul les correctifs suivants.

### Étape 1 : préparer la montée de version

La montée de version prend **15 à 25 minutes**. Azure ajoute un nœud neuf, y déplace les pods, puis retire l'ancien.

**À compléter** dans `aks.tf`, juste sous `kubernetes_version` :

```hcl
  automatic_upgrade_channel = "..."   # À COMPLÉTER : patch
```

**À compléter** dans `default_node_pool` :

```hcl
    upgrade_settings {
      max_surge = "..."               # À COMPLÉTER : 10%
    }
```

**À faire** : dans `variables.tf`, passez la valeur par défaut de `kubernetes_version` de `"1.35"` à `"1.36"`.

> **Explication.**
> - Passer à `"1.36"` met d'abord à jour le **plan de contrôle** (l'API Kubernetes, gérée par Azure), puis **remplace** les nœuds : un nœud ne se met pas à jour sur place.
> - Les nœuds suivent grâce à `orchestrator_version = var.kubernetes_version`, déjà dans `default_node_pool`. Sans cette ligne, Terraform ne monterait que le plan de contrôle, et les nœuds resteraient en 1.35.
> - Pour chaque nœud, AKS **ajoute** un nœud neuf en 1.36, **vide** l'ancien (ses pods sont recréés sur le neuf), puis le **supprime**.
> - `max_surge` : combien de nœuds neufs AKS peut ajouter en même temps, en pourcentage du pool, **arrondi au supérieur**. Avec un nœud, 10 % donne un nœud de plus : 2 vCPU de quota pendant quelques minutes. Sur un pool de 10 nœuds, ce serait aussi un nœud à la fois.
> - `automatic_upgrade_channel = "patch"` : après la montée, Azure applique seul les correctifs de la 1.36 (1.36.1, 1.36.2…). Terraform ne voit pas de différence, puisque le code dit `"1.36"`.

### Étape 2 : lancer la montée de version

**À lancer**, puis **sans attendre**, l'étape 3 dans un second terminal :

```bash
cd ../socle
terraform plan -var-file=dev.tfvars
# 15 à 25 minutes
terraform apply -var-file=dev.tfvars
```

### Étape 3 : observer pendant la mise à jour

**À lancer**, dans un second terminal :

```bash
# Suit les nœuds en direct (Ctrl+C pour arrêter)
kubectl get nodes -w
```

Pendant ce temps, actualisez l'URL de votre application.

**Vérifier** : un nœud en 1.36 apparaît, l'ancien passe en `SchedulingDisabled`, puis disparaît. L'application reste accessible, à quelques secondes près : quand l'ancien nœud est vidé, ses pods mettent un instant à redémarrer sur le neuf. À la fin, `terraform output kubernetes_version` affiche `1.36.x`.

### Étape 4 : vérifier dans le portail

`aks-<prénom>`, menu **Settings > Cluster configuration** (Paramètres > Configuration du cluster) : la version 1.36 et le canal de mise à niveau `patch`.

### Documentation

- [Mettre à niveau un cluster AKS](https://learn.microsoft.com/azure/aks/upgrade-aks-cluster)

### Questions

- Pourquoi un nœud supplémentaire apparaît-il pendant la mise à jour ?
- Que fait `automatic_upgrade_channel = "patch"` ?

</details>

