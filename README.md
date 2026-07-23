## terraform-azurerm-fencer-scanner

Terraform module that provisions the least-privilege, read-only Azure access [Fencer](https://www.fencer.dev)'s
configuration scanning requires. It creates an Entra ID app registration + service principal, generates a
client secret, assigns the built-in **Reader** role plus a custom role with the few extra actions Fencer
needs, and optionally assigns the roles required for container scanning.

This is the Infrastructure-as-Code equivalent of the manual portal steps shown in the Fencer Azure
connection wizard — apply it instead of clicking through them.

### Usage

```hcl
module "fencer_scanner" {
  source  = "Fencer-Security/fencer-scanner/azurerm"
  version = "~> 1.0"

  subscription_id = "00000000-0000-0000-0000-000000000000"
}

output "tenant_id"     { value = module.fencer_scanner.tenant_id }
output "client_id"     { value = module.fencer_scanner.client_id }
output "client_secret" {
  value     = module.fencer_scanner.client_secret
  sensitive = true
}
```

After `terraform apply`, copy the `tenant_id`, `client_id`, and `client_secret`
(`terraform output -raw client_secret`) into the Azure connection form in Fencer.

### Use from Pulumi

Pulumi consumes this module directly — no rewrite. Add it to your project, then instantiate the generated
`Module` component (works in TypeScript, Python, Go, or YAML):

```bash
pulumi package add terraform-module Fencer-Security/fencer-scanner/azurerm 1.0.0 fencerscanner
```

```ts
import * as fencerscanner from "@pulumi/fencerscanner";

const scanner = new fencerscanner.Module("fencer-scanner", {
  subscription_id: "00000000-0000-0000-0000-000000000000",
});

export const tenantId = scanner.tenant_id;
export const clientId = scanner.client_id;
export const clientSecret = scanner.client_secret;
```

Inputs and outputs mirror the module's variables/outputs documented below.

### What gets created

- An Entra ID app registration + service principal (`Fencer Scanner`) with a client secret.
- A **Reader** role assignment at the subscription scope.
- A custom role (`Fencer Scanner Role`) with the additional actions Fencer needs (the exact list lives in
  [`role_actions.txt`](./role_actions.txt)), and its assignment.
- Optionally, `AcrPull` on the listed container registries and `Azure Kubernetes Service Cluster Admin
  Role` on the listed AKS clusters for container scanning.

`role_actions.txt` is generated from Fencer's single source of truth; the console instructions, this
module, and Fencer's connection validation all derive from it, so they never drift apart. Do not edit it
by hand.

> **Security note:** the generated client secret is written into Terraform state. Use a secured, encrypted
> remote backend and treat the state as sensitive.

### Container scanning (optional)

```hcl
module "fencer_scanner" {
  source  = "Fencer-Security/fencer-scanner/azurerm"
  version = "~> 1.0"

  subscription_id = "00000000-0000-0000-0000-000000000000"

  enable_container_scanning = true
  acr_ids                   = ["/subscriptions/.../registries/myregistry"]
  aks_cluster_ids           = ["/subscriptions/.../managedClusters/mycluster"]
}
```

AKS scanning requires local accounts to be enabled on the cluster (the default).

### Custom permissions

By default the custom role uses Fencer's action list (`role_actions.txt`). Supply `override_actions` to
replace it wholesale with a list you own — all-or-nothing, either the default or yours.

```hcl
module "fencer_scanner" {
  source  = "Fencer-Security/fencer-scanner/azurerm"
  version = "~> 1.0"

  subscription_id = "00000000-0000-0000-0000-000000000000"

  override_actions = ["Microsoft.Compute/virtualMachines/read"]
}
```

> **Notes:** when you override, you own keeping the list aligned with what Fencer needs — removing actions
> may cause scan gaps. This affects only the *custom* role; the built-in **Reader** role is always assigned
> and still grants broad `*/read` across the subscription. Container *scanning* (image pull / cluster admin)
> is separately gated behind `enable_container_scanning` and off by default.

### Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | :---: |
| `subscription_id` | Azure subscription to grant scanning access to. | `string` | n/a | yes |
| `application_name` | Display name of the app registration. | `string` | `"Fencer Scanner"` | no |
| `custom_role_name` | Name of the custom role for additional actions. | `string` | `"Fencer Scanner Role"` | no |
| `client_secret_validity` | Client secret lifetime as a Go duration. | `string` | `"17520h"` | no |
| `override_actions` | Full action list to use instead of Fencer's default custom-role actions. | `list(string)` | `null` | no |
| `enable_container_scanning` | Assign the ACR/AKS roles for container scanning. | `bool` | `false` | no |
| `acr_ids` | Container registry resource IDs to grant AcrPull on. | `list(string)` | `[]` | no |
| `aks_cluster_ids` | AKS cluster resource IDs to grant Cluster Admin on. | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
| --- | --- |
| `tenant_id` | Directory (tenant) ID — paste into Fencer. |
| `client_id` | Application (client) ID — paste into Fencer. |
| `client_secret` | Client secret value (sensitive) — paste into Fencer. |
| `subscription_id` | The subscription access was granted to. |

### Requirements

- Terraform `>= 1.5`
- azuread provider `>= 3.0`, azurerm provider `>= 3.0`

### License

[MIT](./LICENSE)
