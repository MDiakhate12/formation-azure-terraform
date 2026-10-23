# Jour 3 : énoncé

Le jour 3 part de code fourni : rien ne dépend de vos TP d'hier.

| Dossier | Contenu |
|---|---|
| `jour3/socle` | Réseau et cluster AKS en Kubernetes 1.35 : à lancer **dès 9h**, la création est longue |
| `jour3/app` | Point de départ de l'application, avec le module `modules/app` |
| `jour3/pannes` | Une application préparée avec trois pannes (TP4) |

Vous travaillez **directement dans ces trois dossiers** du dépôt cloné : remplacez d'abord `prenom` dans chacun des trois `dev.tfvars`.
Les solutions arrivent dans `jour3/solutions/tpN/` après chaque correction (`git pull`).

## Démarrage : relancer le cluster

#### macOS, Linux, Git Bash

```bash
az login --tenant <tenant>
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo $ARM_SUBSCRIPTION_ID
```

#### Windows PowerShell

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

#### Puis le cluster

```bash
cd socle
terraform init
terraform apply -var-file=dev.tfvars      # 5 à 10 minutes
terraform output -raw get_credentials    # copiez-collez la commande affichée : elle écrit le kubeconfig
kubectl get nodes
```

Vous travaillerez ensuite dans `app` et `pannes` : si vous ouvrez un nouveau terminal pour ces dossiers, refaites l'export.

## Sommaire

| TP | Sujet | Durée |
|---|---|---|
| [TP1](#tp1--brancher-terraform-sur-le-cluster) | Brancher Terraform sur le cluster | 30 min |
| [TP2](#tp2--mon-application-en-ligne) | Mon application en ligne | 30 min |
| [TP3](#tp3--exploiter-le-cluster) | Exploiter le cluster | 40 min |
| [TP4](#tp4--pannes-volontaires) | Pannes volontaires | 30 min |
| [TP5](#tp5--démonstration-finale) | Démonstration finale | 30 min |
| [Bonus](#bonus--déployer-un-chart-helm) | Déployer un chart Helm | 20 min |

## Avant de partir

Détruisez dans l'ordre inverse : `pannes`, puis `app`, puis `socle`. Vérifiez qu'il ne reste rien :
`az group list --query "[?starts_with(name, 'rg-<prénom>')].name" -o table`.

## TP1 : brancher Terraform sur le cluster

**Objectif** : configurer le provider `kubernetes` et créer un premier objet dans le cluster. **Durée** : 30 minutes.
**Dossier de travail** : `jour3/app/`

### Étapes

1. Vérifiez que le cluster répond : `kubectl get nodes`, puis `kubectl config current-context` (il doit afficher `aks-<prénom>`).
2. Dans `jour3/app`, créez `providers.tf` avec un provider `kubernetes` :
   - `config_path = "~/.kube/config"` ;
   - `config_context` : le contexte de votre cluster (`aks-<prénom>`).
3. Créez un namespace `app` avec `kubernetes_namespace_v1`.
4. `terraform init`, `apply -var-file=dev.tfvars`, puis `kubectl get ns`.
5. Lisez `modules/app` : quelles variables attend-il ? Lesquelles ont une valeur par défaut ?

### Questions

- Que se passe-t-il si `config_context` désigne le cluster d'un autre participant ?
- Pourquoi déclarer le provider à la racine et pas dans le module ?

### Pour aller plus loin

`terraform state list` : quelles ressources Terraform connaît-il dans le cluster ?


## TP2 : mon application en ligne

**Objectif** : voir votre application tourner sur Internet, avec une adresse fournie par Azure. **Durée** : 30 minutes.
**Dossier de travail** : `jour3/app/`

### Étapes

1. Lisez le registre partagé avec `data "azurerm_container_registry"` (`acrformationtf`, dans `rg-formation-partage`).
2. Appelez le module : `source = "./modules/app"`, `namespace`, `prenom`, `registry` (le `login_server` du data), `tag = "v1"`, `replicas = 2`.
3. Dans le module, ajoutez `frontend-service.tf` : un `kubernetes_service_v1` de type `LoadBalancer`, `selector = { app = "frontend" }`, port `80` vers `target_port = 8080`.
4. Dans `modules/app/outputs.tf`, ajoutez l'output `url` :
   `"http://${kubernetes_service_v1.frontend.status[0].load_balancer[0].ingress[0].ip}"`.
   À la racine, exposez-le en `app_url`.
5. `apply` : l'attente de l'IP publique prend une à deux minutes.
6. Ouvrez l'URL et actualisez : le nom du pod du service A change.
7. Supprimez le pod du service B : `kubectl delete pod -n app -l app=service-b`. Actualisez : le compteur a survécu.

### Questions

- Pourquoi le service B n'a-t-il qu'un réplica ?
- Quel objet Azure a été créé pour votre Service `LoadBalancer` ? Où est-il ?

### Pour aller plus loin

Passez `dns_label_enabled = true` au module et ouvrez `http://tf-<prénom>.swedencentral.cloudapp.azure.com`.


## TP3 : exploiter le cluster

**Objectif** : modifier le cluster en place, avec des labels, l'autoscaler et une montée de version. **Durée** : 40 minutes.
**Dossier de travail** : `jour3/socle/` (et jour3/app/ pour aller plus loin)
Toutes les modifications se font dans `jour3/socle/aks.tf`. **Lisez chaque plan avant de répondre `yes`.**

### Étapes

1. Ajoutez au `default_node_pool` des `tags` (`owner = var.prenom`) et des `node_labels` (`role = "system"`).
   Le plan est-il `~` (en place) ou `-/+` (remplacement) ?
2. Activez l'autoscaler : `auto_scaling_enabled = true`, `min_count = 1`, `max_count = 2`, et retirez `node_count`.
3. Lancez la montée de version **tôt** (15 à 25 minutes) : `kubernetes_version = "1.36"`, puis `apply`.
4. Pendant ce temps, dans un autre terminal : `kubectl get nodes -w`, et actualisez l'URL de votre application.
5. Combien de nœuds voyez-vous pendant la mise à jour ? Votre application a-t-elle été coupée ?

### Questions

- Pourquoi un nœud supplémentaire apparaît-il pendant la mise à jour ?
- Que fait `automatic_upgrade_channel = "patch"` ?

### Pour aller plus loin

Ajoutez un pool `apps` avec le label `role = "apps"` (modèle dans `jour3/socle/node-pool.tf.bonus`),
puis passez `node_selector = { role = "apps" }` au module : sur quel nœud vont les pods ? Détruisez le pool ensuite (quota).


## TP4 : pannes volontaires

**Objectif** : diagnostiquer et corriger trois pannes dans une application préparée. **Durée** : 30 minutes.
**Dossier de travail** : `jour3/pannes/`
Le state de `jour3/pannes` est dans un stockage partagé : chacun a sa propre clé.

### Mise en place

```bash
cd pannes
terraform init -backend-config="key=<prénom>.tfstate"
terraform apply -var-file=dev.tfvars
```

### Les pannes

1. **Un pod reste en `ImagePullBackOff`.** Trouvez la cause avec `kubectl describe pod -n pannes <pod>` (section Events), corrigez le code, `apply`.
2. **Le Service `service-a` n'a pas d'endpoints.** Comparez `kubectl get endpoints -n pannes service-a`, le `selector` du Service et les labels des pods (`kubectl get pods -n pannes --show-labels`).
3. **Un apply est verrouillé.** Lancez `./casser-verrou.sh` (sous Windows : `terraform apply`, puis fermez brutalement la fenêtre), puis `terraform plan -var-file=dev.tfvars`.
   Lisez le message et levez le verrou proprement.

### Puis

Relancez `plan` avec `TF_LOG=DEBUG` et `TF_LOG_PATH=terraform.log`, et repérez un appel à l'API Kubernetes ou Azure dans le fichier.
Sous PowerShell : `$env:TF_LOG = "DEBUG"; $env:TF_LOG_PATH = "terraform.log"`, puis `Remove-Item Env:TF_LOG` pour arrêter.

### Questions

- Pour chaque panne : quelle commande vous a donné la cause ?
- Quand `force-unlock` est-il dangereux ?

### Pour aller plus loin

Supprimez le Service `frontend` avec `kubectl delete svc -n pannes frontend`, puis `terraform plan -refresh-only` : que propose Terraform ?


## TP5 : démonstration finale

**Objectif** : présenter votre application et votre infrastructure en deux minutes. **Durée** : 30 minutes.
**Dossier de travail** : `jour3/socle/` et jour3/app/, ceux de la journée

1. Vérifiez que votre URL répond, après la montée de version.
2. Préparez deux minutes : l'architecture (socle, module, registre), un plan, l'URL.
3. Passez à tour de rôle, en partageant votre écran.
4. Posez une question à un autre participant.
5. Notez ce que vous changeriez en production : nombre de nœuds et zones, state distant, pipeline, identités, Gateway API...

Pour aller plus loin : montrez le nom DNS fourni par Azure plutôt que l'IP.


## Bonus : déployer un chart Helm

**Objectif** : installer une application packagée par Helm, avec Terraform. **Durée** : 20 minutes.
**Dossier de travail** : `jour3/bonus/`

### Étapes

1. Dans `jour3/bonus/`, déclarez le provider `hashicorp/helm` en `~> 3.0`.
   En version 3, la connexion au cluster est un **attribut** : `kubernetes = { config_path = "...", config_context = "..." }`.
2. Créez un `helm_release` :
   - `repository = "https://stefanprodan.github.io/podinfo"`, `chart = "podinfo"`, une `version` fixée ;
   - `namespace = "bonus"`, `create_namespace = true` ;
   - `set` : `replicaCount = 2` et `ui.message` avec votre prénom.
3. `apply`, puis `kubectl get all -n bonus`.
4. `kubectl port-forward -n bonus svc/podinfo 9898:9898` et ouvrez `http://localhost:9898`.

### Questions

- Combien d'objets Kubernetes le chart a-t-il créés ? Combien Terraform en voit-il dans son state ?
- Quand préférer Helm aux ressources `kubernetes_*` ?

Détruisez à la fin : `terraform destroy`.
