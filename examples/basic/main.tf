terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

module "kv" {
  source = "../.."

  name                = "kv-example-001"
  resource_group_name = "rg-example"
  location            = "westeurope"
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

output "vault_uri" {
  value = module.kv.vault_uri
}
