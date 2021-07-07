resource "azurerm_policy_definition" "policy-res" {
  name         = "terragoat-policy-${var.environment}"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "acceptance test policy definition"
  metadata     = <<METADATA
    {
    "category": "Security Center"
    }
METADATA
  policy_rule  = <<POLICY_RULE
    {
    "if": {
      "not": {
        "field": "location",
        "in": "[parameters('allowedLocations')]"
      }
    },
    "then": {
      "effect": "audit"
    }
  }
POLICY_RULE
  parameters   = <<PARAMETERS
    {
    "allowedLocations": {
      "type": "Array",
      "metadata": {
        "description": "The list of allowed locations for resources.",
        "displayName": "Allowed locations",
        "strongType": "location"
      }
    }
  }
PARAMETERS
}

resource "azurerm_subscription_policy_assignment" "example" {
  name                 = "terragoat-policy-assignment-${var.environment}"
  subscription_id      = "{data.azurerm_subscription.current_subscription.id}"
  policy_definition_id = azurerm_policy_definition.policy-res.id
  description          = "Policy Assignment created via an Acceptance Test"
  display_name         = "My Example Policy Assignment"
  parameters           = <<PARAMETERS
{
  "allowedLocations": {
    "value": [ "East US" ]
  }
}
PARAMETERS
}
