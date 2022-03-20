output "key_vault_id" {
  description = "Key vault id"
  value       = azurerm_key_vault.vault.id
}

output "key_vault_uri" {
  description = "Key vault uri"
  value       = azurerm_key_vault.vault.vault_uri
}

output "crypt_keys" {
  value = azurerm_key_vault_key.crypt_key
}

output "private_endpoint" {
  value = var.private_link_subnet != null ? azurerm_private_endpoint.private_endpoint : null
}

