resource "azurerm_key_vault" "example" {
  name                       = "terragoat-key-${var.environment}${random_integer.rnd_int.result}"
  location                   = var.location
  resource_group_name        = var.rg_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  sku_name                   = "premium"  
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.external.user.result.objectId
    key_permissions = [
      "create",
      "get",
      "delete",
      "purge"
    ]
    secret_permissions = [
      "set",
      "get",
      "delete",
      "purge"
    ]
  }
  tags = {
    environment = var.environment
    terragoat   = true
  }
}

resource "azurerm_key_vault_key" "generated" {
  name         = "terragoat-generated-certificate-${var.environment}"
  key_vault_id = azurerm_key_vault.example.id
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
}

resource "azurerm_key_vault_secret" "secret" {
  key_vault_id = azurerm_key_vault.example.id
  name         = "terragoat-secret-${var.environment}"
  value        = random_string.password.result
}


