output "ec2_private_ip" {
  value = module.ec2.private_ip
  description = "Private ip at Monolithic instance"
}

output "monolithic_security_group" {
  value = aws_security_group.ec2.id
}