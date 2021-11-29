resource "azurerm_virtual_network" "example" {
  name                = "terragoat-vn-1"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = rg_name
}
