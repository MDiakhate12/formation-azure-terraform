# Jour 3

Le jour 3 part de code fourni : rien ne dépend de vos TP d'hier.
Les consignes sont dans `tpN/enonce.md`, les solutions dans `tpN/solution/` après chaque correction.

| Dossier | Contenu |
|---|---|
| `jour3/socle` | Réseau et cluster AKS en Kubernetes 1.35 : à lancer **dès 9h**, la création est longue |
| `jour3/app` | Point de départ de l'application, avec le module `modules/app` |
| `jour3/pannes` | Une application préparée avec trois pannes (TP4) |

Copiez les trois dossiers dans votre espace de travail (`~/formation/jour3`) et remplacez `prenom` dans chaque `dev.tfvars`.

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

| TP | Sujet | Durée |
|---|---|---|
| [TP1](tp1/enonce.md) | Brancher Terraform sur le cluster | 30 min |
| [TP2](tp2/enonce.md) | Mon application en ligne | 30 min |
| [TP3](tp3/enonce.md) | Exploiter le cluster | 40 min |
| [TP4](tp4/enonce.md) | Pannes volontaires | 30 min |
| [TP5](tp5/enonce.md) | Démonstration finale | 30 min |
| [Bonus](bonus/enonce.md) | Déployer un chart Helm | 20 min |

## Avant de partir

Détruisez dans l'ordre inverse : `pannes`, puis `app`, puis `socle`. Vérifiez qu'il ne reste rien :
`az group list --query "[?starts_with(name, 'rg-<prénom>')].name" -o table`.
