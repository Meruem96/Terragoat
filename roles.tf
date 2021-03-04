data azurerm_subscription current_subscription {}

resource "azurerm_role_definition" "example" {
  name        = "my_custom_role"
  scope       = data.azurerm_subscription.current_subscription.id
  description = "This is a custom role created via Terraform"

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.current_subscription.id
  ]
}
