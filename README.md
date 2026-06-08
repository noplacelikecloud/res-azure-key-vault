# res-azure-key-vault

Generic, organization-wide resource module that provisions an Azure Key
Vault with RBAC authorization, optional role assignments scoped to the
vault, and optional private endpoint.

## Usage

```hcl
module "kv" {
  source  = "git::https://github.com/noplacelikecloud/res-azure-key-vault.git?ref=v1.0.0"

  name                = "kv-chatbot-prod"
  resource_group_name = "rg-chatbot-prod"
  location            = "westeurope"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  role_assignments = {
    webapp_secrets = {
      principal_id         = azurerm_linux_web_app.app.identity[0].principal_id
      role_definition_name = "Key Vault Secrets User"
    }
  }
}
```

### With private endpoint

```hcl
module "kv" {
  source  = "git::https://github.com/noplacelikecloud/res-azure-key-vault.git?ref=v1.0.0"

  name                = "kv-chatbot-prod"
  resource_group_name = "rg-chatbot-prod"
  location            = "westeurope"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  public_network_access_enabled = false

  private_endpoint = {
    subnet_id            = azurerm_subnet.pe.id
    private_dns_zone_ids = [azurerm_private_dns_zone.kv.id]
  }
}
```

## Inputs

| Name                          | Type                                                                                  | Default     | Description                              |
| ----------------------------- | ------------------------------------------------------------------------------------- | ----------- | ---------------------------------------- |
| name                          | string                                                                                | n/a         | Vault name (3-24 chars).                 |
| resource_group_name           | string                                                                                | n/a         | Resource group.                          |
| location                      | string                                                                                | n/a         | Azure region.                            |
| tenant_id                     | string                                                                                | n/a         | Azure AD tenant ID.                      |
| sku_name                      | string                                                                                | `standard`  | `standard` or `premium`.                 |
| public_network_access_enabled | bool                                                                                  | `true`      | Allow public network access.             |
| purge_protection_enabled      | bool                                                                                  | `false`     | Enable purge protection.                 |
| soft_delete_retention_days    | number                                                                                | `7`         | Soft-delete retention (7-90).            |
| role_assignments              | map(object({principal_id, role_definition_name}))                                     | `{}`        | Vault-scoped role assignments.           |
| private_endpoint              | object({name?, subnet_id, private_dns_zone_ids?}) or null                             | `null`      | Optional private endpoint config.        |
| tags                          | map(string)                                                                           | `{}`        | Tags.                                    |

## Outputs

| Name                | Description                                       |
| ------------------- | ------------------------------------------------- |
| id                  | Full Azure resource ID.                           |
| name                | Vault name.                                       |
| vault_uri           | Vault DNS URI.                                    |
| private_endpoint_id | Private endpoint ID, or null when not created.    |

## Tests

```bash
terraform init -backend=false
terraform test
```
