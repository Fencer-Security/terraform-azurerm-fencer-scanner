terraform {
  required_version = ">= 1.5"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "00000000-0000-0000-0000-000000000000"
}

provider "azuread" {}

module "fencer_scanner" {
  source = "../../"

  subscription_id = "00000000-0000-0000-0000-000000000000"
}

output "tenant_id" {
  value = module.fencer_scanner.tenant_id
}

output "client_id" {
  value = module.fencer_scanner.client_id
}

output "client_secret" {
  value     = module.fencer_scanner.client_secret
  sensitive = true
}
