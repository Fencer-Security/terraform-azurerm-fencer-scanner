output "tenant_id" {
  description = "Directory (tenant) ID. Paste into the Azure connection form in Fencer."
  value       = data.azurerm_subscription.target.tenant_id
}

output "client_id" {
  description = "Application (client) ID of the Fencer Scanner app registration. Paste into Fencer."
  value       = azuread_application.fencer_scanner.client_id
}

output "client_secret" {
  description = "Client secret value. Paste into the Azure connection form in Fencer."
  value       = azuread_application_password.fencer_scanner.value
  sensitive   = true
}

output "subscription_id" {
  description = "The subscription the app was granted access to."
  value       = var.subscription_id
}
