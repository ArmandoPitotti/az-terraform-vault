locals {
  ## Required tags
  tags = {
    CostCenter             = var.tags["CostCenter"]
    WBS                    = var.tags["WBS"]
    Environment            = var.tags["Environment"]
    AppMaintenanceWindows  = var.tags["AppMaintenanceWindows"]
    DataClassification     = var.tags["DataClassification"]
    CompliancyRequirements = var.tags["CompliancyRequirements"]
    SupportProvider        = var.tags["SupportProvider"]
    AccountManagement      = var.tags["AccountManagement"]
    Owner                  = var.tags["Owner"]
    Project                = var.tags["Project"]
  }

  access_ids        = concat(var.access_group_ids, var.access_user_ids)
  manage_access_ids = concat(var.manage_access_group_ids, var.manage_access_user_ids)
}

resource "azurerm_key_vault" "vault" {
  name                = var.name
  resource_group_name = var.resource_group
  location            = var.location

  sku_name = "standard"

  tenant_id = var.tenant_id

  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  purge_protection_enabled        = var.vault_purge_protection_enabled
  soft_delete_retention_days      = var.vault_soft_delete_retention_days

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = var.subnet_ids
    ip_rules                   = coalesce(var.allowed_cidr_blocks, var.allowed_cirds)
  }

  tags = local.tags // in the NVDC enviroment some tags are mandatory

}

resource "azurerm_monitor_diagnostic_setting" "vault-monitor" {
  name                       = "${replace(lower(var.resource_group), "_", "-")}-vault-monitor"
  target_resource_id         = azurerm_key_vault.vault.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "AuditEvent"

    retention_policy {
      enabled = true
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
    }
  }
}

resource "azurerm_key_vault_access_policy" "manage-access" {
  count        = length(local.manage_access_ids)
  key_vault_id = azurerm_key_vault.vault.id

  tenant_id = var.tenant_id
  object_id = local.manage_access_ids[count.index]

  key_permissions = [
    "Get",
    "List",
    "Decrypt",
    "Encrypt",
    "UnwrapKey",
    "WrapKey",
    "Verify",
    "Sign",
    "Create",
    "Update",
    "Import",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge"
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge"
  ]

  certificate_permissions = [
    "Get",
    "List",
    "GetIssuers",
    "ListIssuers",
    "Update",
    "Create",
    "Import",
    "Recover",
    "Backup",
    "Restore",
    "Purge"
  ]

  depends_on = [null_resource.options]
}

resource "azurerm_key_vault_access_policy" "access" {
  count        = length(local.access_ids)
  key_vault_id = azurerm_key_vault.vault.id

  tenant_id = var.tenant_id
  object_id = local.access_ids[count.index]

  key_permissions = [
    "Get",
    "List",
    "Decrypt",
    "Encrypt",
    "UnwrapKey",
    "WrapKey",
    "Verify",
    "Sign"
  ]

  secret_permissions = [
    "Get",
    "List"
  ]

  certificate_permissions = [
    "Get",
    "List",
    "GetIssuers",
    "ListIssuers"
  ]

  depends_on = [null_resource.options]
}

resource "azurerm_key_vault_key" "crypt_key" {
  count = length(var.crypt_keys)

  name         = var.crypt_keys[count.index]
  key_vault_id = azurerm_key_vault.vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [azurerm_key_vault_access_policy.manage-access, null_resource.options]
}

resource "azurerm_private_endpoint" "private_endpoint" {
  count               = var.private_link_subnet != null ? 1 : 0
  name                = "${var.private_link_subnet.virtual_network_name}-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.private_link_subnet.id
  private_service_connection {
    is_manual_connection           = false
    name                           = "${var.private_link_subnet.virtual_network_name}-${var.name}"
    private_connection_resource_id = azurerm_key_vault.vault.id
    subresource_names              = ["vault"]
  }
}
