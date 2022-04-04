resource azurerm_service_plan "example" {
  name                = "terragoat-app-service-plan-${var.environment}"
  location            = var.location
  resource_group_name = var.rg_name

  sku {
    tier = "Dynamic"
    size = "S1"
  }
}

resource azurerm_app_service "app-service1" {
  app_service_plan_id = azurerm_service_plan.example.id
  location            = var.location
  name                = "terragoat-app-service-${var.environment}${random_integer.rnd_int.result}"
  resource_group_name = var.rg_name
  https_only          = false
  site_config {
    min_tls_version = "1.1"
  }
}

resource azurerm_app_service "app-service2" {
  app_service_plan_id = azurerm_service_plan.example.id
  location            = var.location
  name                = "terragoat-app-service-${var.environment}${random_integer.rnd_int.result}"
  resource_group_name = var.rg_name
  https_only          = true

  auth_settings {
    enabled = false
  }
}

