variable "env" {
  description = "Environment name abbreviation, e.g. dev, prod"
  type        = string
  default = "dev"
}
variable "location" {
  description = "The Azure location where all resources should be created"
  type        = string
  default     = "norwayeast"
}
variable "functions_plan_size" {
  description = "Sku size for App Service Plan for functions"
  type        = string
  default     = "EP1"
}
variable "functions_plan_tier" {
  description = "Sku tier for App Service Plan for functions"
  type        = string
  default     = "ElasticPremium"
}
variable "vnet_address" {
  description = "Address space for VNet in CIDR notation, e.g. 10.244.156.0/22"
  type        = string
  default     = "10.0.0.0/21"
}
variable "subnet_address_default" {
  description = "Address prefix for the subnet in CIDR notation"
  type        = string
  default     = "10.0.0.0/24"
}
variable "subnet_address_inbound" {
  description = "Address prefix for the subnet in CIDR notation"
  type        = string
  default     = "10.0.1.0/24"
}
variable "subnet_address_outbound" {
  description = "Address prefix for the subnet in CIDR notation"
  type        = string
  default     = "10.0.2.0/24"
}
