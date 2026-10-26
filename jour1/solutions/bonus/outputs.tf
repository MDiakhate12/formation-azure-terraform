output "private_ip" {
  value = azurerm_network_interface.vm.private_ip_address
}

output "ssh_private_key" {
  value     = tls_private_key.vm.private_key_openssh
  sensitive = true
}
