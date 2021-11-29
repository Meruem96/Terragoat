variable "subscription_id" {
  type        = string
  description = "The subscription ID to be scanned"
  default     = null
}

variable "location" {
  type    = string
  default = "francecentral"
}

variable "rg_name" {
  name = ""
  id   = ""
}
