data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = var.config
}

data "aws_ami" "bastion" {
  most_recent      = true
  owners = ["self"]
  filter {
    name   = "name"
    values = ["bastion"]
  }
}

module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "bastion"

  ami                    = data.aws_ami.bastion.image_id
  instance_type          = "t2.micro"
  key_name               = var.pem
  monitoring             = true
  vpc_security_group_ids = [data.terraform_remote_state.vpc.outputs.bastion-security_group_id]
  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
