output "url" {
  description = "Abra no navegador depois do apply"
  value       = "http://${azurerm_public_ip.lab.ip_address}"
}

output "ssh" {
  description = "Comando de acesso"
  value       = "ssh -i ~/.ssh/tbx_lab ${var.admin_user}@${azurerm_public_ip.lab.ip_address}"
}

output "resource_group" {
  value = azurerm_resource_group.lab.name
}
