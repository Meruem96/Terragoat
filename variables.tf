variable "subscription_id" {
  type        = string
  description = "The subscription ID to be scanned"
  default     = null
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
