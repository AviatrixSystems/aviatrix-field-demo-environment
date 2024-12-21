output "public_ip" {
  value = var.public_ip ? azurerm_linux_virtual_machine.this.public_ip_address : null
}

output "private_ip" {
  value = azurerm_linux_virtual_machine.this.private_ip_address
}
