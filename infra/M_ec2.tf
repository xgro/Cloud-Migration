module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "monolitic"

  ami                    = "ami-0c9bb9182a8d3321f"
  instance_type          = "t2.micro"
  key_name               = "serverInstance"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.monolitic_security_group.id]
  subnet_id              = module.vpc_mono.private_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


module "ec2_instance_bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "bastion"

  ami                    = "ami-0a8bc755297b74eb6"
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
