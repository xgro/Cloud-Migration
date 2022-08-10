module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "monolithic"

  ami                    = data.aws_ami.monolithic.image_id
  instance_type          = "t2.micro"
  key_name               = "serverInstance"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.monolithic_security_group.id]
  subnet_id              = module.vpc_mono.private_subnets[0]

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

module "ec2_instance_bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "bastion"

  ami                    = data.aws_ami.bastion.image_id
  instance_type          = "t2.micro"
  key_name               = "bsHost"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id              = module.vpc_mono.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

data "aws_ami" "bastion" {
  most_recent      = true
  owners = ["self"]
  filter {
    name   = "name"
    values = ["bastion"]
  }
}