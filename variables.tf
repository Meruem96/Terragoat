variable "subscription_id" {
  type        = string
  description = "The subscription ID to be scanned"
  default     = null
}

variable "location" {
  type    = string
  default = "francecentral"
}

variable "environment" {
  default     = "dev"
  description = "Must be all lowercase letters or numbers"
}

variable "kuber_version" {
  type    = string
  default = "1.18.19"
}

variable "rg_name" {
  type = string
}
