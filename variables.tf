variable "name" {}
variable "tenant_id" {}
variable "resource_group" {}
variable "location" {}
variable "log_analytics_workspace_id" {}

variable "subnet_ids" {
  type    = list
  default = []
}

variable "manage_access_group_ids" {
  type    = list
  default = []
}

variable "manage_access_user_ids" {
  type    = list
  default = []
}

variable "access_group_ids" {
  type    = list
  default = []
}

variable "access_user_ids" {
  type    = list
  default = []
}

variable "crypt_keys" {
  type    = list
  default = []
}

# TODO: Remove when everyone has moved to allowed_cidr_blocks
variable "allowed_cirds" {
  type    = list
  default = []
}

# https://nokia.sharepoint.com/sites/it/netcon/WAN/Pages/Webproxy.aspx
variable "allowed_cidr_blocks" {
  type    = list
  default = []
}

variable "tags" {
  type        = map
  description = "Map of mandatory NVDC tags"
}

variable "private_link_subnet" {
  default = null
}

variable "purge_protection_enabled" {
  type = bool
  description = "Prevent from remove keyvault when soft-delete is enabled. By default Soft-delete is always enabled(new behavior from 08/20/2021)"
  default = true
}
variable "soft_delete_retention_days"{
  type = number
  description = "From 7 days to 90 days"
  default = 7
}