# Jour 2

Chaque TP est autonome et a son dossier : travaillez directement dedans (`cd jour2/tp1`). Rien ne dépend du travail d'hier.
Vos fichiers ne sont pas suivis par git : `git pull` ne les touche pas.
Bloqué ? La solution de chaque TP est publiée juste après sa correction dans `jour2/tpN/solution` : `git pull`, puis copiez-la.

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

Pour ne plus y penser, ajoutez-la au démarrage de vos terminaux (à retirer après la formation) :

- macOS (zsh) : `echo 'export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)' >> ~/.zshrc`
- Windows : `setx ARM_SUBSCRIPTION_ID (az account show --query id -o tsv)`, valable pour les **prochains** terminaux uniquement.

Rappels : préfixe par votre prénom, région `swedencentral`, taille `Standard_D2as_v6`, **aucune zone** sur les nœuds.

| TP | Sujet | Durée |
|---|---|---|
| [TP1](tp1/enonce.md) | Un state distant | 30 min |
| [TP2](tp2/enonce.md) | Importer et déplacer | 30 min |
| [TP3](tp3/enonce.md) | Une identité managée avec un rôle | 40 min |
| [TP4](tp4/enonce.md) | Premier pipeline | 30 min |
| [TP5](tp5/enonce.md) | Mon cluster AKS | 50 min |
| [Bonus](bonus/enonce.md) | Un pipeline sans secret (OIDC) | 30 min |

**Avant de partir** : `terraform destroy` sur le cluster du TP5. Il coûte à l'heure, et demain le code du cluster est fourni.
