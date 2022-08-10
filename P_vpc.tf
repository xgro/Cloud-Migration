# VPC for Product API 구현 
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "final_product-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2b"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  
  enable_nat_gateway = false
  enable_vpn_gateway = false

  # VPC_ENDPOINT 구축시 필요한 설정
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}