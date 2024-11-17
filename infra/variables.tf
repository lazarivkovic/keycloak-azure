variable "resource_group_name" {
  type        = string
  description = "Resource group name"
  default     = "keycloak-vm-rg"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "West Europe"
}

variable "admin_username" {
  type        = string
  description = "Admin username for VM"
  default = "lazar"
}
