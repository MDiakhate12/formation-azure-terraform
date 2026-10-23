# Bonus : une VM configurée par cloud-init

**Objectif** : déployer une machine virtuelle dont la configuration est générée par `templatefile`. **Durée** : 30 minutes.

## Où on en est, où on va

Ce bonus est **autonome** : il ne touche pas au réseau du fil rouge. Vous créez un resource group `rg-<prénom>-vm`, un petit réseau, puis une VM Linux qui installe un serveur web toute seule à son premier démarrage.

La VM consomme 2 vCPU du quota partagé : **détruisez-la à la fin**.

## Étape 1 : un dossier à part

Ce code a son propre state : il ne doit pas se mélanger à celui du fil rouge.

**À lancer** :

```bash
# Nouveau dossier, à côté de celui du fil rouge
mkdir -p ~/formation/jour1-bonus
cd ~/formation/jour1-bonus
```

**À copier** depuis votre dossier du fil rouge : `variables.tf` (gardez seulement `prenom` et `location`) et `dev.tfvars` (seulement la ligne `prenom`).

## Étape 2 : les providers

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

## Étape 3 : le resource group et le réseau

**À écrire** dans `main.tf`, en reprenant le code du TP3 :
- un resource group `"rg-${var.prenom}-vm"` ;
- un VNet `"vnet-${var.prenom}-vm"` en `10.0.0.0/16` (`address_space = ["10.0.0.0/16"]`, sans variable) ;
- un sous-réseau `app` nommé `snet-app`, en `10.0.1.0/24`.

## Étape 4 : une carte réseau sans IP publique

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

> [!NOTE]
> **Explication.** `ip_configuration` est un **bloc imbriqué** : il relie la carte au sous-réseau. `"Dynamic"` : Azure choisit l'adresse privée.

## Étape 5 : une clé SSH

**À copier** à la suite :

```hcl
resource "tls_private_key" "vm" {
  algorithm = "ED25519"
}
```

> [!NOTE]
> **Explication.** La clé est générée par Terraform et stockée **en clair dans le state** : acceptable pour un TP, pas en production.

## Étape 6 : le script de démarrage

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

> [!NOTE]
> **Explication.** `templatefile(fichier, valeurs)` lit le fichier et remplace chaque `${...}` par la valeur donnée. `path.module` : le dossier du code courant.

## Étape 7 : la VM

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

> [!NOTE]
> **Explication.**
> - Pas d'argument `zone` : la création ne dépend pas de la capacité d'une zone précise.
> - `custom_data` : le script passé à la VM, encodé en base64.
> - `disk_controller_type = "NVMe"` : obligatoire, cette taille n'accepte que des disques NVMe.
> - `admin_ssh_key` : la clé publique autorisée à se connecter. Aucun mot de passe.
> - `source_image_reference` : l'image du système, ici Ubuntu 24.04.

## Étape 8 : les sorties, puis le déploiement

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

## Étape 9 : retrouver la VM dans le portail

1. Ouvrez `rg-<prénom>-vm` : la VM, sa carte réseau, son disque (`vm-<prénom>_OsDisk_...`), le VNet. Azure a créé le disque pour vous.
2. Ouvrez `vm-<prénom>` : **Overview** (Vue d'ensemble) affiche la taille `Standard_D2as_v6` et l'adresse IP privée. Comparez avec `terraform output private_ip`.
3. Menu **Operations > Run command** (Opérations > Exécuter la commande), choisissez **RunShellScript**, tapez `curl -s localhost` et lancez.
   Après une à deux minutes, la sortie affiche votre page : cloud-init a installé nginx.

## Étape 10 : détruire

La VM coûte tant qu'elle existe.

**À lancer** :

```bash
# Supprime la VM et tout le reste de ce dossier (tapez yes)
terraform destroy -var-file=dev.tfvars
```

## Documentation

- [`azurerm_network_interface`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface)
- [`azurerm_linux_virtual_machine`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine)
- [`tls_private_key`](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key)
- [`templatefile`](https://developer.hashicorp.com/terraform/language/functions/templatefile)

## Pour aller plus loin

Ajoutez une IP publique et une règle NSG qui autorise SSH depuis votre seule adresse IP, connectez-vous
(`terraform output -raw ssh_private_key > cle && chmod 600 cle`, puis `ssh -i cle azureuser@<ip>`), puis retirez l'IP publique.
Sous Windows, faites cette étape dans Git Bash : PowerShell n'applique pas `chmod`.
