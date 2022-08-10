variable "secrets" {
  type = string
  //fake
  default = "JWT_SECRET"
}

variable "api_gateway_name" {
  type = string
  //fake
  default = "aacompany_endpoint"
}

variable "domain_name" {
  type = string
  //fake
  default = "api.xgro.be"
}

variable "ECR_repo" {
  type = string
  //fake
  default = "stock-management-api"
}