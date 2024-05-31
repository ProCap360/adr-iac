output "ssh_private_key" {
    value = tls_private_key.adr.private_key_openssh
    sensitive = true
}
output "vm_ip_address" {
    value = azurerm_public_ip.adr.ip_address
}