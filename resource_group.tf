resource "azurerm_resource_group" "example" {
  name     = "terragoat-${var.environment}"
  location = var.location
}

resource "azurerm_resource_group" "example1" {
  name     = var.terragoatrg
  location = var.location
}
