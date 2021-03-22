provider "azurerm" {
  subscription_id = var.subscription_id
  key_vault {
    pruge_soft_delete_on_destroy = true
  }
  features {}
}


data "azurerm_client_config" "current" {}

terraform {
  required_version = ">=0.12.0"
  backend "azurerm" {
    required_version = ">= 2.0.0"
  }
}

