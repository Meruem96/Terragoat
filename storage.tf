resource "azurerm_managed_disk" "example" {
  name                 = "terragoat-disk-${var.environment}"
  location             = var.location
  resource_group_name  = azurerm_resource_group.example.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 1
  encryption_settings {
    enabled = false
  }
}


resource "azurerm_storage_account" "example" {
  name                     = "tgsa${var.environment}${random_integer.rnd_int.result}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = var.network_watcher_location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  queue_properties {
    logging {
      delete                = false
      read                  = false
      write                 = true
      version               = "1.0"
      retention_policy_days = 10
    }
    hour_metrics {
      enabled               = true
      include_apis          = true
      version               = "1.0"
      retention_policy_days = 10
    }
    minute_metrics {
      enabled               = true
      include_apis          = true
      version               = "1.0"
      retention_policy_days = 10
    }
  }
}

resource "azurerm_storage_account" "example1" {
  name                      = "${var.storage_account_name}${random_integer.rnd_int.result}"
  resource_group_name       = azurerm_resource_group.example1.name
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  access_tier               = "StorageV2"
  enable_https_traffic_only = true 
}

resource "azurerm_storage_container" "example" {
  name                  = "terragoat-container"
  storage_account_name  = azurerm_storage_account.example1.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "example" {
  name                   = "terragoat-blob"
  storage_account_name   = azurerm_storage_account.example1.name
  storage_container_name = azurerm_storage_container.example.name
  type                   = "Block"
}



resource "azurerm_storage_account_network_rules" "test" {
  resource_group_name  = azurerm_resource_group.example.name
  storage_account_name = azurerm_storage_account.example.name

  default_action             = "Allow"
  ip_rules                   = ["127.0.0.1"]
  bypass                     = ["Metrics"]
}
