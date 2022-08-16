variable "config" {
  type = map 
}

variable "db_instance_identifier" {
  type = string
}

variable "vpc_id" {
  type = string
  default = data.terraform_remote_state.vpc
}