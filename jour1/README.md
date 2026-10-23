# Jour 1

Chaque TP a son dossier : `tpN/enonce.md` pour les consignes, `tpN/solution/` pour la solution, publiée après la correction.

Un fil rouge sur la journée : un resource group, puis un réseau, puis un module réutilisable.
Travaillez dans **votre propre dossier** (par exemple `~/formation/jour1`), en dehors du clone du dépôt, et faites-le évoluer de TP en TP.

Bloqué ? La solution de chaque TP est publiée juste après sa correction : `git pull`, puis copiez le contenu de `jour1/tpN/solution` dans votre dossier et repartez de là.

## Lire les énoncés

Chaque étape d'un TP commence par une phrase qui dit **pourquoi** on la fait, puis un ou plusieurs repères :

| Repère | Ce que vous faites |
|---|---|
| **À copier** | Recopiez le bloc tel quel dans le fichier indiqué. C'est du code déjà prêt (souvent un prérequis). |
| **À compléter** | Recopiez le bloc, puis remplacez chaque `...` : le commentaire `# À COMPLÉTER : ...` sur la même ligne dit quoi mettre. |
| **À écrire** | Écrivez le bloc vous-même, à partir de la consigne et du modèle des étapes précédentes. |
| **À lancer** | Tapez les commandes dans le terminal, dans votre dossier de travail, une par une. La ligne `#` au-dessus de chaque commande dit ce qu'elle fait. |
| **Vérifier** | Ce que vous devez obtenir. Si ce n'est pas le cas, arrêtez-vous et demandez. |

> [!NOTE]
> **Explication.** Les encadrés comme celui-ci expliquent le code ou les commandes. Ils sont à lire : il n'y a rien à faire.

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

| TP | Sujet | Durée |
|---|---|---|
| [TP1](tp1/enonce.md) | Mon premier resource group | 30 min |
| [TP2](tp2/enonce.md) | Variabiliser et nommer | 30 min |
| [TP3](tp3/enonce.md) | VNet et deux sous-réseaux | 40 min |
| [TP4](tp4/enonce.md) | NSG et règles avec `for_each` | 30 min |
| [TP5](tp5/enonce.md) | Module réseau | 50 min |
| [Bonus](bonus/enonce.md) | Une VM configurée par cloud-init | 30 min |
