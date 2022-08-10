module "vpc_mono" {
  source = "terraform-aws-modules/vpc/aws"

  name = "final_monolithic-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2b"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  public_subnets  = ["10.0.1.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}