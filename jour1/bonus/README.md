# Bonus : une VM configurée par cloud-init

**Objectif** : déployer une machine virtuelle dont la configuration est générée par `templatefile`. **Durée** : 30 minutes.
Ce TP est autonome : il crée son propre resource group (`rg-<prénom>-vm`), son VNet et son sous-réseau.

## Étapes

1. Créez un resource group, un VNet `10.0.0.0/16` et un sous-réseau `snet-app` `10.0.1.0/24`.
2. Créez une `azurerm_network_interface` dans `snet-app`, **sans IP publique**.
3. Générez une clé SSH avec la ressource `tls_private_key` (algorithme `ED25519`, provider `hashicorp/tls`).
4. Créez une `azurerm_linux_virtual_machine` :
   - taille `Standard_B2s_v2`, **sans** argument `zone` ;
   - image Ubuntu 24.04 : `Canonical`, `ubuntu-24_04-lts`, `server`, `latest` ;
   - `custom_data = base64encode(templatefile("cloud-init.tftpl", { ... }))`.
5. Écrivez `cloud-init.tftpl` : il fixe le nom d'hôte, installe `nginx` et écrit une page d'accueil avec votre prénom.
6. Vérifiez dans le portail (onglet Diagnostics de démarrage ou Exécuter une commande), puis **détruisez la VM**.

La VM consomme 2 vCPU du quota partagé : ne la laissez pas tourner.

## Pour aller plus loin

Ajoutez une IP publique et une règle NSG qui autorise SSH depuis votre seule adresse IP, connectez-vous
(`terraform output -raw ssh_private_key > cle && chmod 600 cle`, puis `ssh -i cle azureuser@<ip>`), puis retirez l'IP publique.
Sous Windows, faites cette étape dans Git Bash : PowerShell n'applique pas `chmod`.
