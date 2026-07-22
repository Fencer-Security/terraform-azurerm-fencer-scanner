locals {
  # By default the additional actions Fencer's configuration scanning requires beyond the built-in
  # Reader role, generated from Fencer's single source of truth (do not edit role_actions.txt by
  # hand). Supply override_actions to replace the list wholesale with actions you control.
  scanner_actions = var.override_actions != null ? var.override_actions : split("\n", trimspace(file("${path.module}/role_actions.txt")))

  subscription_scope = "/subscriptions/${var.subscription_id}"

  acr_ids         = var.enable_container_scanning ? toset(var.acr_ids) : toset([])
  aks_cluster_ids = var.enable_container_scanning ? toset(var.aks_cluster_ids) : toset([])
}

data "azurerm_subscription" "target" {
  subscription_id = var.subscription_id
}

resource "azuread_application" "fencer_scanner" {
  display_name     = var.application_name
  sign_in_audience = "AzureADMyOrg"
}

resource "azuread_service_principal" "fencer_scanner" {
  client_id = azuread_application.fencer_scanner.client_id
}

resource "azuread_application_password" "fencer_scanner" {
  application_id    = azuread_application.fencer_scanner.id
  display_name      = "Fencer Scanner secret"
  end_date_relative = var.client_secret_validity
}

resource "azurerm_role_definition" "fencer_scanner" {
  name        = var.custom_role_name
  scope       = local.subscription_scope
  description = "Additional actions Fencer's configuration scanning requires beyond Reader."

  permissions {
    actions = local.scanner_actions
  }

  assignable_scopes = [local.subscription_scope]
}

resource "azurerm_role_assignment" "reader" {
  scope                = local.subscription_scope
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.fencer_scanner.object_id
}

resource "azurerm_role_assignment" "custom" {
  scope              = local.subscription_scope
  role_definition_id = azurerm_role_definition.fencer_scanner.role_definition_resource_id
  principal_id       = azuread_service_principal.fencer_scanner.object_id
}

resource "azurerm_role_assignment" "acr_pull" {
  for_each             = local.acr_ids
  scope                = each.value
  role_definition_name = "AcrPull"
  principal_id         = azuread_service_principal.fencer_scanner.object_id
}

resource "azurerm_role_assignment" "aks_admin" {
  for_each             = local.aks_cluster_ids
  scope                = each.value
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = azuread_service_principal.fencer_scanner.object_id
}
