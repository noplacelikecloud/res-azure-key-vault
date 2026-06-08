mock_provider "azurerm" {}

variables {
  name                = "kvunittest001"
  resource_group_name = "rg-unit-test"
  location            = "westeurope"
  tenant_id           = "00000000-0000-0000-0000-000000000000"
}

run "plan_defaults" {
  command = plan

  assert {
    condition     = azurerm_key_vault.this.sku_name == "standard"
    error_message = "Default SKU should be 'standard'."
  }

  assert {
    condition     = azurerm_key_vault.this.rbac_authorization_enabled == true
    error_message = "RBAC authorization must always be enabled."
  }

  assert {
    condition     = azurerm_key_vault.this.public_network_access_enabled == true
    error_message = "Default public access should be enabled."
  }

  assert {
    condition     = length(azurerm_role_assignment.this) == 0
    error_message = "No role assignments should be created when input map is empty."
  }

  assert {
    condition     = length(azurerm_private_endpoint.this) == 0
    error_message = "No private endpoint should be created when input is null."
  }
}

run "plan_with_role_assignment" {
  command = plan

  variables {
    name                = "kvrole001"
    resource_group_name = "rg-unit-test"
    location            = "westeurope"
    tenant_id           = "00000000-0000-0000-0000-000000000000"
    role_assignments = {
      app_secrets = {
        principal_id         = "11111111-1111-1111-1111-111111111111"
        role_definition_name = "Key Vault Secrets User"
      }
    }
  }

  assert {
    condition     = length(azurerm_role_assignment.this) == 1
    error_message = "Exactly one role assignment should have been planned."
  }

  assert {
    condition     = azurerm_role_assignment.this["app_secrets"].role_definition_name == "Key Vault Secrets User"
    error_message = "Role definition name was not propagated."
  }
}

run "plan_with_private_endpoint" {
  command = plan

  variables {
    name                          = "kvpe001"
    resource_group_name           = "rg-unit-test"
    location                      = "westeurope"
    tenant_id                     = "00000000-0000-0000-0000-000000000000"
    public_network_access_enabled = false
    private_endpoint = {
      subnet_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-net/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
      private_dns_zone_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-net/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"]
    }
  }

  assert {
    condition     = length(azurerm_private_endpoint.this) == 1
    error_message = "Private endpoint should be created when input is set."
  }

  assert {
    condition     = azurerm_private_endpoint.this[0].name == "kvpe001-pe"
    error_message = "Default private endpoint name should be '<vault>-pe'."
  }
}
