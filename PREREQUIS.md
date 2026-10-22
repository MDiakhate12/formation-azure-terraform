# Prérequis : Azure Terraform, Infrastructure Automation

Session du 26 au 28 octobre 2026, 9h-17h, en classe virtuelle.
Merci de tout préparer **avant le premier jour** : une installation qui bloque le matin, c'est une heure de TP perdue.

## 1. Avant la session : deux actions à faire

- **Acceptez l'invitation Azure.** Vous recevrez un e-mail de Microsoft (« invitation à rejoindre... ») sur l'adresse transmise à l'organisme de formation. Cliquez sur le lien et acceptez. Sans cela, pas d'accès à la subscription de formation.
- **Ayez un compte GitHub** (gratuit) : il sert au TP sur les pipelines CI/CD du jour 2. Vérifiez que vous pouvez vous y connecter et créer un dépôt.

Vous n'avez **pas** besoin de subscription Azure personnelle, ni de Docker.

## 2. Le poste de travail

- Windows 10/11, macOS ou Linux, avec **les droits d'installer des logiciels**.
- Accès Internet sans blocage vers : `*.azure.com`, `login.microsoftonline.com`, `*.azmk8s.io` (port 443), `github.com`, `registry.terraform.io`, `releases.hashicorp.com`. Un proxy d'entreprise est la cause de blocage la plus fréquente : testez depuis le poste que vous utiliserez.
- Casque avec micro et caméra. Un second écran est fortement conseillé (le support d'un côté, votre terminal de l'autre).

## 3. Les outils

| Outil | Version | Rôle |
|---|---|---|
| Terraform | **1.16** (1.15 minimum) | L'outil du cours |
| Azure CLI (`az`) | 2.80 ou plus récente | Connexion à Azure |
| kubectl | **1.35 ou plus récent** | Piloter le cluster Kubernetes (jours 2 et 3) |
| git | récente | Récupérer le code des TP, pipeline du jour 2 |
| VS Code | récente, avec l'extension **HashiCorp Terraform** | Éditeur conseillé (tout autre éditeur convient) |

### Windows (PowerShell)

```powershell
winget install --id Hashicorp.Terraform
winget install --id Microsoft.AzureCLI
winget install --id Kubernetes.kubectl
winget install --id Git.Git
winget install --id Microsoft.VisualStudioCode
```

Fermez puis rouvrez le terminal après l'installation. Git Bash, installé avec git, est utile pour un script du jour 3 (facultatif).

### macOS (Homebrew)

Installez les outils **un par un**, et vérifiez chacun avant de passer au suivant : si l'un échoue, vous savez lequel.
Pas encore de Homebrew ? Voir [brew.sh](https://brew.sh).

1. Terraform :

```bash
brew tap hashicorp/tap
```

```bash
brew install hashicorp/tap/terraform
```

```bash
terraform version
```

2. Azure CLI :

```bash
brew install azure-cli
```

```bash
az version
```

3. kubectl :

```bash
brew install kubernetes-cli
```

```bash
kubectl version --client
```

4. git (souvent déjà présent) :

```bash
git --version || brew install git
```

5. VS Code :

```bash
brew install --cask visual-studio-code
```

Si `brew` affiche « Tier 3 configuration » ou se met à compiler pendant de longues minutes, votre version de macOS n'est plus prise en charge par Homebrew : arrêtez (Ctrl+C) et prévenez l'organisme de formation avant la session, une autre méthode d'installation existe.

### Linux

Suivez les pages officielles : [Terraform](https://developer.hashicorp.com/terraform/install), [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli-linux), [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/).

## 4. Vérification (5 minutes)

Lancez ces commandes : chacune doit répondre sans erreur.

```bash
terraform version          # Terraform v1.16.x (ou v1.15.x)
az version                 # "azure-cli": "2.8x" ou plus
kubectl version --client   # Client Version: v1.35 ou plus
git --version
az login                   # une page de connexion s'ouvre dans le navigateur
```

Si `az login` ouvre bien la page de connexion, votre poste est prêt. Le premier jour, vous vous connecterez au tenant de la formation avec la commande donnée par le formateur.

## 5. Connaissances utiles

- À l'aise avec un terminal : se déplacer dans les dossiers, lancer une commande, lire une erreur.
- Bases de git : `clone`, `commit`, `push`.
- Notions de réseau : adresse IP, sous-réseau, notation CIDR (`10.0.0.0/16`).
- Des notions de conteneurs et de Kubernetes aident pour le jour 3, mais ne sont pas obligatoires.

## Un problème ?

Si une installation échoue ou si votre poste est verrouillé, prévenez l'organisme de formation **avant la session** : une solution de repli (poste distant) peut être prévue.

Supports et code des TP : <https://github.com/MDiakhate12/formation-azure-terraform>
