output "keycloak_public_ip" {
  value       = azurerm_public_ip.keycloak_public_ip.ip_address
  description = "Public IP address of the Keycloak VM"
}

output "admin_username" {
  value       = azurerm_linux_virtual_machine.keycloak-vm.admin_username
  description = "Admin username for the Keycloak VM"
}

output "private_key_pem" {
  description = "Private SSH Key for the VM"
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
}