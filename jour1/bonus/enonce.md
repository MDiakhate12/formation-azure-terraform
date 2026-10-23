# Bonus : une VM configurée par cloud-init

**Objectif** : déployer une machine virtuelle dont la configuration est générée par `templatefile`. **Durée** : 30 minutes.
Ce TP est autonome : il crée son propre resource group (`rg-<prénom>-vm`), son VNet et son sous-réseau.

La VM consomme 2 vCPU du quota partagé : **détruisez-la à la fin**.

## 1. Les providers

Dans `versions.tf`, ajoutez `hashicorp/tls` à côté d'`azurerm` :

```hcl
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
```

- `tls` : un provider qui fabrique des clés et des certificats, sans appeler aucun cloud.

## 2. Le réseau

Un resource group, un VNet `10.0.0.0/16` et un sous-réseau `snet-app` `10.0.1.0/24` : reprenez le code du TP3.

## 3. Une carte réseau sans IP publique

```hcl
resource "azurerm_network_interface" "vm" {
  name                = "nic-<prénom>"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "interne"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
  }
}
```

- `ip_configuration` : un **bloc imbriqué**. Il relie la carte au sous-réseau.
- `"Dynamic"` : Azure choisit l'adresse privée dans le sous-réseau.

## 4. Une clé SSH

```hcl
resource "tls_private_key" "vm" {
  algorithm = "ED25519"
}
```

- La clé est générée par Terraform et stockée **en clair dans le state** : acceptable pour un TP, pas en production.

## 5. Le script de démarrage

Créez `cloud-init.tftpl` :

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
```

Et dans `main.tf` :

```hcl
locals {
  cloud_init = templatefile("${path.module}/cloud-init.tftpl", {
    hostname = "vm-${var.prenom}"
    prenom   = var.prenom
  })
}
```

- `cloud-init` : le standard qui configure une VM Linux à son premier démarrage.
- `templatefile(fichier, valeurs)` : lit un fichier et remplace les `${...}` par les valeurs données.
- `path.module` : le dossier du code courant.

## 6. La VM

```hcl
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "vm-${var.prenom}"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  size                  = "Standard_D2as_v6"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.vm.id]
  custom_data           = base64encode(local.cloud_init)
  disk_controller_type  = "NVMe"

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.vm.public_key_openssh
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

- `size` : la taille de la VM, ici 2 vCPU et 8 Go. Ne mettez **pas** d'argument `zone`.
- `custom_data` : le script passé à la VM, encodé en base64 (`base64encode`).
- `disk_controller_type = "NVMe"` : obligatoire, cette taille n'accepte que des disques NVMe.
- `admin_ssh_key` : la clé publique autorisée à se connecter. Aucun mot de passe.
- `source_image_reference` : l'image du système (Ubuntu 24.04).

## 7. Retrouver la VM dans le portail

1. Ouvrez `rg-<prénom>-vm` : la VM, sa carte réseau, son disque (`vm-<prénom>_OsDisk_...`), le VNet. Azure a créé le disque pour vous.
2. Ouvrez `vm-<prénom>` : **Overview** (Vue d'ensemble) affiche la taille `Standard_D2as_v6` et l'adresse IP privée. Comparez avec `terraform output private_ip`.
3. Menu **Operations > Run command** (Opérations > Exécuter la commande), choisissez **RunShellScript**, tapez `curl -s localhost` et lancez.
   Après une à deux minutes, la sortie affiche votre page : cloud-init a installé nginx.

## 8. Détruire

La VM coûte tant qu'elle existe :

```bash
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
