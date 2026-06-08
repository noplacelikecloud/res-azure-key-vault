variable "name" {
  description = "Name of the Key Vault (3-24 lowercase alphanumeric chars, must be globally unique)."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.name))
    error_message = "Key Vault name must be 3-24 chars and contain only letters, digits and hyphens."
  }
}

variable "resource_group_name" {
  description = "Resource group in which the vault is created."
  type        = string
}

variable "location" {
  description = "Azure region for the vault."
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID the vault is associated with."
  type        = string
}

variable "sku_name" {
  description = "Key Vault SKU (standard or premium)."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be either 'standard' or 'premium'."
  }
}

variable "public_network_access_enabled" {
  description = "Whether public network access to the vault is allowed."
  type        = bool
  default     = true
}

variable "purge_protection_enabled" {
  description = "Whether purge protection is enabled."
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "Soft-delete retention in days (7-90)."
  type        = number
  default     = 7

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "soft_delete_retention_days must be between 7 and 90."
  }
}

variable "role_assignments" {
  description = <<-EOT
    Map of role assignments scoped to this vault. The map key is an
    arbitrary stable identifier (used as the resource address suffix);
    the value provides the principal and role definition.
  EOT
  type = map(object({
    principal_id         = string
    role_definition_name = string
  }))
  default = {}
}

variable "private_endpoint" {
  description = <<-EOT
    Optional private endpoint configuration. When set, a private
    endpoint targeting the 'vault' subresource is created.
  EOT
  type = object({
    name                 = optional(string)
    subnet_id            = string
    private_dns_zone_ids = optional(list(string), [])
  })
  default = null
}

variable "tags" {
  description = "Map of tags applied to the vault."
  type        = map(string)
  default     = {}
}
