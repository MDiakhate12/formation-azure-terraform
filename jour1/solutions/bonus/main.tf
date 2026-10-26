locals {
  cloud_init = templatefile("${path.module}/cloud-init.tftpl", {
    hostname = "vm-${var.prenom}"
    prenom   = var.prenom
  })
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prenom}-vm"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.prenom}-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "vm" {
  name                = "nic-${var.prenom}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "interne"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Clé générée par Terraform pour le TP : elle est stockée en clair dans le state.
resource "tls_private_key" "vm" {
  algorithm = "ED25519"
}

# Pas de zone : la création ne dépend pas de la capacité d'une zone précise.
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "vm-${var.prenom}"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  size                  = "Standard_D2as_v6"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.vm.id]
  custom_data           = base64encode(local.cloud_init)

  # La D2as_v6 n'accepte que des disques NVMe.
  disk_controller_type = "NVMe"

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
