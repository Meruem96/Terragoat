provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}


data "azurerm_client_config" "current" {}

terraform {
  required_providers {
    version = ">= 2.0.0"
  }
  required_version = ">=0.12.0"
  backend "azurerm" {
  }
}
