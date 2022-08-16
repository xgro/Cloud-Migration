variable "domain" {
  type = string
  description = "Name of Domain"  
}

variable "api_gateway_name" {
  type = string
  description = "Name of api_gateway"
}

variable "function_name" {
  type = string
  description = "authorizer function name"
}

variable "config_monolithic_vpc" {
  type = map
  description = "configure monolithic vpc"
}

variable "config_monolithic" {
  type = map
  description = "configure monolithic instance"
}

variable "config_product_vpc" {
  type = map
  description = "configure product vpc"
}

variable "config_product" {
  type = map
  description = "configure product instance"
}