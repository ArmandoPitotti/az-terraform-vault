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
