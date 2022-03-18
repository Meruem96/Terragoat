variable "subscription_id" {
  type        = string
  description = "The subscription ID to be scanned"
  default     = null
}

variable "location" {
  type    = string
  default = "norwayeast"
}

variable "location_nw" {
  type    = string
  default = "norwayeast"
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
variable "sa_id" {
  type = string
}

variable "timezone" {
  default = "Central Europe Standard Time"
}
