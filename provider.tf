provider "azurerm" {
  subscription_id = var.subscription_id
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
  skip_provider_registration = true
}


# Fetch current user info using the az cli
# Not possible to get the object_id of current user
# Terraform retreive object_id via command execution
# command ex: az ad signed-in-user show --query "{key:value}"
data "external" "user" {
  program = ["az", "ad", "signed-in-user", "show", "--query", "{displayName: displayName,objectId: objectId,objectType: objectType,upn: upn}"]
}

data "external" "rg" {
  program = ["rg.sh"]
}
data "azurerm_client_config" "current" {}

#data "azurerm_resource_group" "example" {
  #name = data.externale.rg.name
#}

output "user" {
  value = data.external.user
}

output "rg" {
  value = data.external.rg
}
