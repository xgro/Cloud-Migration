output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "Public subnet IDs at Monolithic VPC"
}

output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "Private subnet IDs at Monolithic VPC"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC_id at Monolithic project"
}

output "ecs-security_group_id" {
  value       = aws_security_group.ecs_security_group.id
  description = "bastion security_group_id at bastion"
}

output "lb-security_group_id" {
  value       = aws_security_group.lb_security_group.id
  description = "bastion security_group_id at bastion"
}

