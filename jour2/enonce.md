# Jour 2 : énoncé

## Table des matières

| Partie | Sujet | Durée |
|---|---|---|
| [Prérequis](#lire-les-énoncés) | Lire les énoncés, se connecter à Azure | 5 min |
| [TP1](tp1/README.md) | Un state distant | 30 min |
| [TP2](tp2/README.md) | Importer et déplacer | 30 min |
| [TP3](tp3/README.md) | Une identité managée avec un rôle | 40 min |
| [TP4](tp4/README.md) | Premier pipeline | 30 min |
| [TP5](tp5/README.md) | Mon cluster AKS | 50 min |
| [Bonus](bonus/README.md) | Un pipeline sans secret (OIDC) | 30 min |
| [Bonus 2](bonus2/README.md) | Une infrastructure en équipe | 30 min |

Chaque TP est autonome et a son dossier dans le dépôt cloné : travaillez directement dedans (`cd jour2/tp1`). Le fichier `versions.tf` y est déjà. Rien ne dépend du travail d'hier.
Vos fichiers ne sont pas suivis par git : `git pull` ne les touche pas.
Bloqué ? La solution de chaque TP est publiée juste après sa correction dans `jour2/solutions/tpN/` : `git pull`, puis copiez-la dans le dossier du TP.

## Lire les énoncés

Les mêmes repères qu'au jour 1 :

| Repère | Ce que vous faites |
|---|---|
| **À copier** | Recopiez le bloc tel quel dans le fichier indiqué. |
| **À compléter** | Recopiez le bloc, puis remplacez chaque `...` : le commentaire `# À COMPLÉTER : ...` dit quoi mettre. |
| **À écrire** | Écrivez le bloc vous-même, à partir de la consigne. |
| **À lancer** | Tapez les commandes dans le terminal, dans le dossier de travail du TP. La ligne `#` au-dessus dit ce que fait chaque commande. |
| **Vérifier** | Ce que vous devez obtenir. Sinon, arrêtez-vous et demandez. |

> **Explication.** Ces citations expliquent le code : à lire, rien à faire.

Tout ce qui est entre chevrons `< >` est à remplacer, chevrons compris : `rg-<prénom>-tfstate` devient `rg-alexandre-tfstate`.

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

## Les TP

Chaque énoncé est dans le dossier de son TP : cliquez pour l'ouvrir.

| TP | Sujet | Durée |
|---|---|---|
| [TP1](tp1/README.md) | Un state distant | 30 min |
| [TP2](tp2/README.md) | Importer et déplacer | 30 min |
| [TP3](tp3/README.md) | Une identité managée avec un rôle | 40 min |
| [TP4](tp4/README.md) | Premier pipeline | 30 min |
| [TP5](tp5/README.md) | Mon cluster AKS | 50 min |
| [Bonus](bonus/README.md) | Un pipeline sans secret (OIDC) | 30 min |
| [Bonus 2](bonus2/README.md) | Une infrastructure en équipe | 30 min |

**Avant de partir** : `terraform destroy` sur le cluster du TP5. Il coûte à l'heure, et demain le code du cluster est fourni.
