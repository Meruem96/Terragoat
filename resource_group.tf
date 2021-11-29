resource "azurerm_resource_group" "example" {
  name     = "${data.rg.value}"
}
