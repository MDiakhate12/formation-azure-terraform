# Jour 3 : énoncés

Le jour 3 part de code fourni : rien ne dépend de vos TP d'hier.

| Dossier | Contenu |
|---|---|
| `jour3/socle` | Réseau et cluster AKS en Kubernetes 1.35 : à lancer **dès 9h**, la création est longue |
| `jour3/app` | Point de départ de l'application, avec le module `modules/app` |
| `jour3/pannes` | Une application préparée avec trois pannes (TP4) |

Copiez les trois dossiers dans votre espace de travail (`~/formation/jour3`) et remplacez `prenom` dans chaque `dev.tfvars`.

## Démarrage : relancer le cluster

```bash
az login --tenant <tenant>
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
cd socle
terraform init
terraform apply -var-file=dev.tfvars      # 5 à 10 minutes
terraform output -raw get_credentials    # copiez-collez la commande affichée : elle écrit le kubeconfig
kubectl get nodes
```

Sous Windows PowerShell : `$env:ARM_SUBSCRIPTION_ID = (az account show --query id -o tsv)`.

| TP | Sujet | Durée |
|---|---|---|
| [TP1](tp1.md) | Brancher Terraform sur le cluster | 30 min |
| [TP2](tp2.md) | Mon application en ligne | 30 min |
| [TP3](tp3.md) | Exploiter le cluster | 40 min |
| [TP4](tp4.md) | Pannes volontaires | 30 min |
| [TP5](tp5.md) | Démonstration finale | 30 min |
| [Bonus](../bonus/README.md) | Déployer un chart Helm | 20 min |

## Avant de partir

Détruisez dans l'ordre inverse : `pannes`, puis `app`, puis `socle`. Vérifiez qu'il ne reste rien :
`az group list --query "[?starts_with(name, 'rg-<prénom>')].name" -o table`.
