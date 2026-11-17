variable "subscription_id" {
  type        = string
  description = "ID of the Azure subscription to grant Fencer configuration scanning access to."
}

variable "application_name" {
  type        = string
  description = "Display name of the Entra ID app registration Fencer authenticates as."
  default     = "Fencer Scanner"
}

variable "custom_role_name" {
  type        = string
  description = "Name of the custom role holding the additional actions Fencer requires beyond Reader."
  default     = "Fencer Scanner Role"
}

variable "client_secret_validity" {
  type        = string
  description = "Lifetime of the generated client secret, as a Go duration (default 730 days)."
  default     = "17520h"
}

variable "override_actions" {
  type        = list(string)
  description = "Replace Fencer's default custom-role action list entirely with this list. Leave null to use the default. Note the built-in Reader role is always assigned, so it still grants broad read regardless of this list."
  default     = null
}

variable "override_data_actions" {
  type        = list(string)
  description = "Replace Fencer's default custom-role data action list entirely with this list. Leave null to use the default; an empty list means Fencer cannot read your Microsoft Foundry agents."
  default     = null
}

variable "enable_container_scanning" {
  type        = bool
  description = "Assign the roles required to scan container images in Azure Container Registry and AKS."
  default     = false
}

variable "acr_ids" {
  type        = list(string)
  description = "Resource IDs of the Azure Container Registries to grant AcrPull on when container scanning is enabled."
  default     = []
}

variable "aks_cluster_ids" {
  type        = list(string)
  description = "Resource IDs of the AKS clusters to grant Cluster Admin on when container scanning is enabled."
  default     = []
}
