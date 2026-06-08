output "id" {
  description = "Full Azure resource ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "Key Vault name."
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "DNS URI of the Key Vault (https://<name>.vault.azure.net/)."
  value       = azurerm_key_vault.this.vault_uri
}

output "private_endpoint_id" {
  description = "Resource ID of the private endpoint (null when none was created)."
  value       = length(azurerm_private_endpoint.this) > 0 ? azurerm_private_endpoint.this[0].id : null
}
