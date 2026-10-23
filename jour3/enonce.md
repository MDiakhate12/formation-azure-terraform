# Jour 3 : énoncé

Le jour 3 part de **code fourni** : rien ne dépend de vos TP d'hier.

| Dossier | Contenu |
|---|---|
| `jour3/socle/` | Le réseau et le cluster AKS en Kubernetes 1.35 : à lancer **dès 9h**, la création est longue |
| `jour3/app/` | Le point de départ de l'application, avec le module `modules/app` déjà écrit |
| `jour3/pannes/` | Une application préparée avec trois pannes (TP4) |

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

> [!NOTE]
> **Explication.** Ces encadrés expliquent le code : à lire, rien à faire.

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

## Démarrage : relancer le cluster

**Dossier de travail** : `jour3/socle/`

Le cluster d'hier a été détruit pour ne pas payer la nuit. Le code fourni recrée un réseau et un cluster identiques, en Kubernetes 1.35 : une version en arrière, pour pratiquer la montée de version au TP3.

**À compléter**, dans **chacun** des trois fichiers `socle/dev.tfvars`, `app/dev.tfvars` et `pannes/dev.tfvars` :

```hcl
prenom = "<prénom>"   # À COMPLÉTER : votre prénom, par exemple "alexandre"
```

**À lancer**, depuis la racine du dépôt cloné :

```bash
cd jour3/socle
terraform init
# Crée le réseau et le cluster : 5 à 10 minutes (tapez yes)
terraform apply -var-file=dev.tfvars
# Affiche la commande qui écrit les accès du cluster dans ~/.kube/config
terraform output -raw get_credentials
# Copiez-collez la commande affichée, puis vérifiez le nœud :
kubectl get nodes
```

**Vérifier** : `kubectl get nodes` affiche un nœud `Ready`. Pendant la création, le formateur fait le rappel de la veille.

> [!NOTE]
> **Explication.** Le socle contient un VNet, un sous-réseau `snet-aks`, une identité managée pour le cluster (avec le rôle `Network Contributor` sur ce sous-réseau) et le cluster `aks-<prénom>`. Lisez `aks.tf` pendant l'attente : vous le modifierez au TP3.

## Sommaire

| TP | Sujet | Dossier | Durée |
|---|---|---|---|
| [TP1](#tp1--brancher-terraform-sur-le-cluster) | Brancher Terraform sur le cluster | `jour3/app/` | 30 min |
| [TP2](#tp2--mon-application-en-ligne) | Mon application en ligne | `jour3/app/` | 30 min |
| [TP3](#tp3--exploiter-le-cluster) | Exploiter le cluster | `jour3/socle/` | 40 min |
| [TP4](#tp4--pannes-volontaires) | Pannes volontaires | `jour3/pannes/` | 30 min |
| [TP5](#tp5--démonstration-finale) | Démonstration finale | | 30 min |
| [Bonus](#bonus--déployer-un-chart-helm) | Déployer un chart Helm | `jour3/bonus/` | 20 min |

## Avant de partir

Détruisez dans l'ordre inverse de la création. **À lancer**, depuis `jour3/` :

```bash
# D'abord l'application des pannes et l'application, puis le cluster
cd pannes && terraform destroy -var-file=dev.tfvars && cd ..
cd app && terraform destroy -var-file=dev.tfvars && cd ..
cd socle && terraform destroy -var-file=dev.tfvars && cd ..
# Il ne doit plus rien rester à votre nom
az group list --query "[?starts_with(name, 'rg-<prénom>')].name" -o table
```

## TP1 : brancher Terraform sur le cluster

**Objectif** : configurer le provider `kubernetes` et créer un premier objet dans le cluster. **Durée** : 30 minutes.
**Dossier de travail** : `jour3/app/`

### Où on en est, où on va

Votre cluster tourne. Jusqu'ici, Terraform ne parlait qu'à Azure : il ne sait pas créer d'objets **dans** Kubernetes.
À la fin de ce TP, Terraform parlera aussi à l'API du cluster, et vous y aurez créé un premier objet : le namespace `app`, qui accueillera l'application au TP2.

### Étape 1 : vérifier la connexion au cluster

**À lancer** :

```bash
# Le nœud doit être Ready
kubectl get nodes
# Le contexte courant doit être celui de VOTRE cluster
kubectl config current-context
```

**Vérifier** : le contexte affiché est `aks-<prénom>`. Sinon, relancez la commande `get_credentials` du démarrage.

> [!NOTE]
> **Explication.** Un **contexte** kubectl désigne un cluster et un utilisateur. Plusieurs clusters dans `~/.kube/config` : se tromper de contexte, c'est déployer sur le cluster de quelqu'un d'autre.

### Étape 2 : découvrir le dossier fourni

**À lancer** :

```bash
cd ../app
ls
```

> [!NOTE]
> **Explication.** Le dossier contient déjà `versions.tf` (providers `azurerm` et `kubernetes`), `variables.tf` (`prenom` et `kube_context`), `dev.tfvars`, et le module `modules/app` que vous appellerez au TP2.

### Étape 3 : le provider kubernetes

**À compléter** dans un nouveau fichier `providers.tf` :

```hcl
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = coalesce(var.kube_context, "aks-${...}")   # À COMPLÉTER : la variable du prénom
}
```

> [!NOTE]
> **Explication.**
> - `config_path` : le fichier écrit par `az aks get-credentials`. Le provider s'y connecte comme `kubectl`.
> - `coalesce(a, b)` renvoie la première valeur non vide : `kube_context` si vous l'avez donné, sinon `aks-<prénom>`.

### Étape 4 : le namespace

Un **namespace** est un espace de noms dans le cluster : il range les objets d'une même application.

**À compléter** dans un nouveau fichier `namespace.tf` :

```hcl
resource "kubernetes_namespace_v1" "app" {
  metadata {
    name   = "..."                    # À COMPLÉTER : app
    labels = { owner = ... }          # À COMPLÉTER : la variable du prénom
  }
}
```

> [!NOTE]
> **Explication.** Les ressources du provider kubernetes 3 finissent par `_v1` : c'est la version de l'API Kubernetes qu'elles utilisent.

### Étape 5 : créer le namespace

**À lancer** :

```bash
terraform init
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
# Liste les namespaces du cluster : app doit y être
kubectl get ns
```

**Vérifier** : le plan annonce `1 to add`, et `kubectl get ns` montre `app`.

### Étape 6 : lire le module fourni

**À faire** : ouvrez `modules/app/variables.tf`. Quelles variables le module attend-il ? Lesquelles ont une valeur par défaut ? Vous l'appellerez au TP2.

### Étape 7 : retrouver le namespace dans le portail

1. Ouvrez votre cluster `aks-<prénom>`, menu **Kubernetes resources > Namespaces** (Ressources Kubernetes > Espaces de noms).
2. `app` y figure, avec le label `owner`.

### Documentation

- [Le provider kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [`kubernetes_namespace_v1`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1)

### Questions

- Que se passe-t-il si `config_context` désigne le cluster d'un autre participant ?
- Pourquoi déclarer le provider à la racine et pas dans le module ?

### Pour aller plus loin

**À lancer** : `terraform state list`. Quelles ressources Terraform connaît-il dans le cluster ?

## TP2 : mon application en ligne

**Objectif** : voir votre application tourner sur Internet, avec une adresse fournie par Azure. **Durée** : 30 minutes.
**Dossier de travail** : `jour3/app/`

### Où on en est, où on va

Le namespace `app` existe. Les images de l'application (un frontend, un service A, un service B) sont dans le registre partagé `acrformationtf`.
À la fin de ce TP, l'application tournera dans votre cluster et sera visible sur Internet, à une adresse IP créée par Azure. Le service B garde un compteur de visites sur un disque qui survit aux pods.

### Étape 1 : lire le registre partagé

**À écrire** dans un nouveau fichier `main.tf` : un `data "azurerm_container_registry" "acr"` qui lit le registre `acrformationtf` du resource group `rg-formation-partage`.

### Étape 2 : appeler le module

Le module `modules/app` contient les trois déploiements, le disque et les services internes. Vous l'appelez avec quelques valeurs.

**À compléter** à la suite, dans `main.tf` :

```hcl
module "app" {
  source    = "./modules/app"
  namespace = kubernetes_namespace_v1.app.metadata[0].name
  prenom    = var.prenom
  registry  = ...              # À COMPLÉTER : l'attribut login_server du registre de l'étape 1
  tag       = "..."            # À COMPLÉTER : v1
  replicas  = ...              # À COMPLÉTER : 2
}
```

> [!NOTE]
> **Explication.**
> - `kubernetes_namespace_v1.app.metadata[0].name` : le nom du namespace du TP1. La référence garantit qu'il existe avant l'application.
> - `registry` vaut `acrformationtf.azurecr.io` : les images s'y tirent sans authentification.

### Étape 3 : exposer le frontend sur Internet

Un Service de type `LoadBalancer` demande à Azure une IP publique, et dirige le trafic vers les pods du frontend. C'est le seul composant exposé.

**À compléter** dans un nouveau fichier `modules/app/frontend-service.tf` (dans le **module**) :

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

> [!NOTE]
> **Explication.**
> - `selector` relie le Service aux pods qui portent ce label : c'est ainsi qu'il sait où envoyer le trafic.
> - `port` est le port exposé, `target_port` celui sur lequel écoute le conteneur.
> - `annotations` : un nom DNS optionnel (voir « Pour aller plus loin »). Vide par défaut.

### Étape 4 : récupérer l'adresse

L'IP est attribuée par Azure **après** la création : elle se lit dans le statut du Service.

**À copier** à la fin de `modules/app/outputs.tf` :

```hcl
locals {
  lb = kubernetes_service_v1.frontend.status[0]
}

output "url" {
  value = "http://${local.lb.load_balancer[0].ingress[0].ip}"
}
```

> [!NOTE]
> **Explication.** `status[0].load_balancer[0].ingress[0].ip` descend dans le statut du Service : le premier point d'entrée du load balancer, puis son adresse IP.

**À écrire** dans un nouveau fichier `outputs.tf` (à la racine de `app/`) : un output `app_url` qui affiche `module.app.url`.

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

**À compléter** dans l'appel du module : ajoutez `dns_label_enabled = true`, puis `apply`.
Ouvrez ensuite `http://tf-<prénom>.swedencentral.cloudapp.azure.com` : un nom fourni par Azure, sans aucune configuration DNS.

## TP3 : exploiter le cluster

**Objectif** : modifier le cluster en place : labels, autoscaler, puis montée de version. **Durée** : 40 minutes.
**Dossier de travail** : `jour3/socle/`

### Où on en est, où on va

Votre application tourne sur un cluster en 1.35, à un seul nœud fixe.
À la fin de ce TP, le cluster aura des tags et des labels, un autoscaler de 1 à 2 nœuds, et il sera passé en 1.36, sans couper l'application. **Lisez chaque plan avant de répondre `yes`.**

Toutes les modifications se font dans `jour3/socle/aks.tf`, dans le bloc `default_node_pool`, sauf la version.

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

> [!NOTE]
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

### Étape 3 : la montée de version

La montée de version prend **15 à 25 minutes** : lancez-la tôt. Azure ajoute un nœud neuf, y déplace les pods, puis retire l'ancien.

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

> [!NOTE]
> **Explication.**
> - `automatic_upgrade_channel = "patch"` : Azure appliquera ensuite tout seul les correctifs (1.36.x).
> - `max_surge` : combien de nœuds supplémentaires pendant la mise à jour. Avec un nœud, 10 % arrondi donne un nœud de plus : 2 vCPU de quota pendant la montée.

**À lancer**, puis **sans attendre**, l'étape 4 dans un second terminal :

```bash
terraform plan -var-file=dev.tfvars
# 15 à 25 minutes
terraform apply -var-file=dev.tfvars
```

### Étape 4 : observer pendant la mise à jour

**À lancer**, dans un second terminal :

```bash
# Suit les nœuds en direct (Ctrl+C pour arrêter)
kubectl get nodes -w
```

Pendant ce temps, actualisez l'URL de votre application.

**Vérifier** : un nœud supplémentaire apparaît, puis l'ancien disparaît. L'application reste accessible. À la fin, `terraform output kubernetes_version` affiche `1.36.x`.

### Étape 5 : vérifier dans le portail

1. `aks-<prénom>`, menu **Settings > Cluster configuration** (Paramètres > Configuration du cluster) : la version 1.36 et le canal de mise à niveau `patch`.
2. Menu **Settings > Node pools** (Paramètres > Pools de nœuds) : le pool `system`, autoscaler de 1 à 2, avec le label `role=system`.
3. Le resource group `MC_rg-<prénom>-j3_aks-<prénom>_swedencentral`, le groupe de machines virtuelles des nœuds (`aks-system-...`), menu **Tags** (Étiquettes) : `owner`. Les tags du pool s'appliquent aux nœuds.

### Documentation

- [`azurerm_kubernetes_cluster`, bloc `default_node_pool`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)
- [Mettre à niveau un cluster AKS](https://learn.microsoft.com/azure/aks/upgrade-aks-cluster)

### Questions

- Pourquoi un nœud supplémentaire apparaît-il pendant la mise à jour ?
- Que fait `automatic_upgrade_channel = "patch"` ?

### Pour aller plus loin

Ajoutez un pool `apps` et placez-y l'application.

**À lancer**, dans `jour3/socle/` :

```bash
# Le modèle fourni devient un fichier Terraform actif : un pool de nœuds avec le label role = apps
mv node-pool.tf.bonus node-pool.tf
terraform apply -var-file=dev.tfvars
```

Puis, dans `jour3/app/main.tf`, ajoutez `node_selector = { role = "apps" }` à l'appel du module, et `apply` dans `app/`.
Sur quel nœud vont les pods (`kubectl get pods -n app -o wide`) ? Détruisez le pool ensuite : il double vos vCPU.

## TP4 : pannes volontaires

**Objectif** : diagnostiquer et corriger trois pannes dans une application préparée. **Durée** : 30 minutes.
**Dossier de travail** : `jour3/pannes/`

### Où on en est, où on va

Le dossier `pannes` déploie une petite application dans le namespace `pannes`, avec **trois pannes cachées**.
À la fin de ce TP, vous les aurez trouvées et corrigées, avec les commandes de diagnostic de Kubernetes et de Terraform. Le code n'est pas commenté : à vous de chercher.

### Étape 1 : déployer l'application en panne

Le state de ce dossier est dans un stockage partagé de la formation : chacun y a son propre fichier, sa **clé**.

**À lancer** :

```bash
cd ../pannes
# Configure le backend partagé, avec un fichier de state à votre nom
terraform init -backend-config="key=<prénom>.tfstate"
terraform apply -var-file=dev.tfvars
# Regardez l'état des pods
kubectl get pods -n pannes
```

> [!NOTE]
> **Explication.** `-backend-config` complète le bloc `backend` de `versions.tf` au moment de l'`init`. C'est la façon de passer une valeur qui change d'une personne à l'autre, puisqu'un backend n'accepte pas de variables.

### Étape 2 : panne 1, un pod qui ne démarre pas

**Vérifier** : un pod est en `ImagePullBackOff` ou `ErrImagePull`.

**À lancer** :

```bash
# Détaille le pod : lisez la section Events, tout en bas
kubectl describe pod -n pannes <nom-du-pod>
```

**À faire** : trouvez la cause dans les Events, corrigez `main.tf`, puis `terraform apply -var-file=dev.tfvars`.

**Vérifier** : `kubectl get pods -n pannes` montre le pod `Running`.

### Étape 3 : panne 2, un Service qui ne mène nulle part

**À lancer** :

```bash
# Les endpoints d'un Service : les adresses des pods vers lesquels il envoie le trafic
kubectl get endpoints -n pannes service-a
# Les pods et leurs labels
kubectl get pods -n pannes --show-labels
```

**Vérifier** : le Service `service-a` n'a **aucun** endpoint, alors que ses pods tournent.

**À faire** : comparez le `selector` du Service dans `main.tf` et les labels des pods. Corrigez, puis `apply`.

**Vérifier** : `kubectl get endpoints -n pannes service-a` affiche deux adresses.

### Étape 4 : panne 3, un state verrouillé

**À lancer** :

```bash
# Interrompt brutalement un apply en cours : le verrou reste posé
./casser-verrou.sh
# Le plan suivant ne peut pas prendre le verrou
terraform plan -var-file=dev.tfvars
```

Sous Windows sans Git Bash : lancez `terraform apply -var-file=dev.tfvars`, puis fermez brutalement la fenêtre du terminal pendant qu'il attend.

**Vérifier** : `Error acquiring the state lock`, avec un **ID** de verrou.

**À faire** : levez le verrou avec la commande prévue par Terraform, en lui donnant cet ID, puis relancez le `plan`.

> [!NOTE]
> **Explication.** `terraform force-unlock <ID>` lève un verrou. À n'utiliser **que** si vous êtes sûr que plus personne n'est en train de travailler sur ce state.

### Étape 5 : les journaux détaillés de Terraform

**À lancer** :

```bash
# Active les journaux détaillés, écrits dans un fichier
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
terraform plan -var-file=dev.tfvars
# Désactive les journaux
unset TF_LOG TF_LOG_PATH
```

Sous PowerShell : `$env:TF_LOG = "DEBUG"; $env:TF_LOG_PATH = "terraform.log"`, puis `Remove-Item Env:TF_LOG, Env:TF_LOG_PATH`.

**À faire** : ouvrez `terraform.log` et repérez un appel à l'API Kubernetes (une ligne avec `GET` ou `https://`).

### Documentation

- [Déboguer des pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/)
- [`terraform force-unlock`](https://developer.hashicorp.com/terraform/cli/commands/force-unlock)
- [Les journaux de Terraform](https://developer.hashicorp.com/terraform/internals/debugging)

### Questions

- Pour chaque panne : quelle commande vous a donné la cause ?
- Quand `force-unlock` est-il dangereux ?

### Pour aller plus loin

Supprimez un objet derrière le dos de Terraform, puis demandez-lui ce qui a changé.

**À lancer** :

```bash
# Supprime le Service frontend directement dans le cluster
kubectl delete svc -n pannes frontend
# Compare le state à la réalité, sans rien modifier
terraform plan -var-file=dev.tfvars -refresh-only
```

Que propose Terraform ? Puis `terraform apply -var-file=dev.tfvars` le recrée.

## TP5 : démonstration finale

**Objectif** : présenter votre application et votre infrastructure en deux minutes. **Durée** : 30 minutes.
**Dossier de travail** : `jour3/socle/` et `jour3/app/`

### Étape 1 : vérifier que tout tourne

**À lancer** :

```bash
# Dans jour3/app/ : l'adresse de l'application
terraform output app_url
# Dans jour3/socle/ : la version du cluster, après la montée de version
terraform output kubernetes_version
```

**Vérifier** : l'URL répond, et la version est `1.36.x`.

### Étape 2 : préparer deux minutes

1. L'architecture : le socle (réseau, cluster), le module `app`, le registre partagé.
2. Un `terraform plan` en direct, et ce qu'il annonce.
3. L'URL de l'application, ouverte devant tout le monde.

### Étape 3 : présenter

Passez à tour de rôle, en partageant votre écran. Posez une question à un autre participant.

### Étape 4 : et en production ?

Notez ce que vous changeriez : nombre de nœuds et zones, state distant, pipeline, identités, Gateway API...

Pour aller plus loin : montrez le nom DNS fourni par Azure plutôt que l'IP (TP2, « Pour aller plus loin »).

## Bonus : déployer un chart Helm

**Objectif** : installer une application packagée par Helm, avec Terraform. **Durée** : 20 minutes.
**Dossier de travail** : `jour3/bonus/`

### Où on en est, où on va

Au TP2, vous avez décrit chaque objet Kubernetes un par un. **Helm** est le gestionnaire de paquets de Kubernetes : un « chart » installe tout un ensemble d'objets d'un coup.
Vous allez installer `podinfo`, une petite application de démonstration, avec le provider `helm` de Terraform.

### Étape 1 : le provider helm

**À lancer** :

```bash
cd ../bonus
```

**À copier** dans un nouveau fichier `versions.tf` :

```hcl
terraform {
  required_version = ">= 1.15.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = coalesce(var.kube_context, "aks-${var.prenom}")
  }
}
```

> [!NOTE]
> **Explication.** Avec le provider helm 3, la connexion au cluster est un **attribut** (`kubernetes = { ... }`, avec un `=`), plus un bloc : une différence avec la version 2 qu'on trouve encore dans beaucoup d'exemples.

### Étape 2 : les variables

**À lancer** :

```bash
# Reprend les variables et les valeurs de l'application
cp ../app/variables.tf ../app/dev.tfvars .
```

**À copier** à la fin de `variables.tf` :

```hcl
variable "chart_version" {
  type        = string
  description = "Version du chart podinfo (helm search repo podinfo --versions)"
  default     = "6.15.0"
}
```

### Étape 3 : le chart

**À compléter** dans un nouveau fichier `main.tf` :

```hcl
resource "helm_release" "podinfo" {
  name             = "podinfo"
  repository       = "https://stefanprodan.github.io/podinfo"
  chart            = "..."                  # À COMPLÉTER : podinfo
  version          = var.chart_version
  namespace        = "..."                  # À COMPLÉTER : bonus
  create_namespace = true

  set = [
    { name = "replicaCount", value = "..." },                                         # À COMPLÉTER : 2
    { name = "ui.message", value = "Déployé par ${var.prenom} avec Helm et Terraform" },
  ]
}
```

> [!NOTE]
> **Explication.**
> - `repository` et `chart` : où trouver le paquet, et lequel. `version` le fige : le même code installe toujours la même version.
> - `set` : des valeurs qui remplacent celles du chart, comme le nombre de réplicas.

**À copier** dans un nouveau fichier `outputs.tf` :

```hcl
output "status" {
  value = helm_release.podinfo.status
}

output "acces" {
  value = "kubectl port-forward -n bonus svc/podinfo 9898:9898, puis http://localhost:9898"
}
```

### Étape 4 : installer et ouvrir

**À lancer** :

```bash
terraform init
terraform apply -var-file=dev.tfvars
# Tous les objets créés par le chart
kubectl get all -n bonus
# Ouvre un tunnel vers l'application (Ctrl+C pour arrêter)
kubectl port-forward -n bonus svc/podinfo 9898:9898
```

**Vérifier** : l'output `status` vaut `deployed`, et `http://localhost:9898` affiche votre message.

### Documentation

- [`helm_release`](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)

### Questions

- Combien d'objets Kubernetes le chart a-t-il créés ? Combien Terraform en voit-il dans son state ?
- Quand préférer Helm aux ressources `kubernetes_*` ?

### Pour finir

**À lancer** : `terraform destroy -var-file=dev.tfvars`.
