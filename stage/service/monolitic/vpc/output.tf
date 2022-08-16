output "public_subnets" {
  value = module.vpc.public_subnets
  description = "Public subnet IDs at Monolithic VPC"
}

output "private_subnets" {
  value = module.vpc.private_subnets
  description = "Private subnet IDs at Monolithic VPC"
}

output "vpc_id" {
  value = module.vpc.vpc_id
  description = "VPC_id at Monolithic project"
}

output "bastion-security_group_id" {
  value = aws_security_group.bastion.id
  description = "bastion security_group_id at bastion"
}

output "monolithic-security_group_id" {
  value = aws_security_group.monolithic.id
  description = "monolithic security_group_id at monolithic"
}

output "rds-security_group_id" {
  value = aws_security_group.rds.id
  description = "rds security_group_id at monolithic"
}