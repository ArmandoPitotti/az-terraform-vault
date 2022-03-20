# Overview

Terraform module to provide Azure Key Vault.

## Usage

```terraform
variable "tenant_id" {}

# Soft-delete has been set on so we it disables recreation of vault with same name.
# Lets use some random characters on vault name so it unique every time.
resource "random_id" "vault" {
  byte_length = 4
}

module "vault" {
  source = "git::ssh://git@gitlabe2.ext.net.nokia.com/cs/common/iac/az-terraform-vault?ref=<version>"

  name                       = "${local.variable.project_vault_name}-${random_id.vault.hex}"
  tenant_id                  = var.tenant_id
  resource_group             = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  access_group_ids           = local.variable.project_access_group_ids
  access_user_ids            = local.variable.pipeline_application_ids
  subnet_ids                 = [module.nokia.subnet.id]
  log_analytics_workspace_id = local.variable.log_analytics_workspace_id != null ? local.variable.log_analytics_workspace_id : module.logs.log_analytics_workspace_id
  crypt_keys                 = ["default-storage-key", "default-database-key"]
  allowed_cirds              = local.variable.allowed_cidrs
  tags                       = local.variable.tags
  private_link_enabled       = true
  private_link_subnet        = lookup(module.nokia.subnets, "Zone-High1", null) 
}
```

Replace `master` with version tag to prevent module auto-update.

## Outputs

See outputs from [outputs.tf](outputs.tf)
