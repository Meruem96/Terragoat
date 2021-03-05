data "azurerm_subscription" "current" {
}

variable "subscription_id" {
  type        = string
  description = "The subscription ID to be scanned"
  default     = null
}

output "current_subscription_display_name" {
  value = data.azurerm_subscription.current.display_name
}

output "subscription_id_value" {
  value = var.subscription_id
}

variable "location" {
  type    = string
  default = "East US"
}

variable "network_watcher_location" {
   type    = string
   default = "West US"
 }

variable "kuber_location" {
  type    = string
  default = "East US 2"
}

variable "environment" {
  default     = "dev"
  description = "Must be all lowercase letters or numbers"
}
