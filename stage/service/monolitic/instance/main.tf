data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = var.config
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "monolithic"

  ami                    = data.aws_ami.monolithic.image_id
  instance_type          = "t2.micro"
  key_name               = var.pem
  monitoring             = true
  vpc_security_group_ids = [data.terraform_remote_state.vpc.outputs.monolithic-security_group_id]
  subnet_id              = data.terraform_remote_state.vpc.outputs.private_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

data "aws_ami" "monolithic" {
  most_recent      = true
  owners = ["self"]
  filter {
    name   = "name"
    values = ["monolithic"]
  }
}