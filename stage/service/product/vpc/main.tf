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

# Load balancer security group. CIDR and port ingress can be changed as required.
resource "aws_security_group" "lb_security_group" {
  description = "LoadBalancer Security Group"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "sg_ingress_rule_all_to_lb" {
  type              = "ingress"
  description       = "Allow from anyone on port 80"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.lb_security_group.id
}

# Load balancer security group egress rule to ECS cluster security group.
resource "aws_security_group_rule" "sg_egress_rule_lb_to_ecs_cluster" {
  type                     = "egress"
  description              = "Target group egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb_security_group.id
  source_security_group_id = aws_security_group.ecs_security_group.id
}

# ECS cluster security group.
resource "aws_security_group" "ecs_security_group" {
  description = "ECS Security Group"
  vpc_id      = module.vpc.vpc_id
  egress {
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS cluster security group ingress from the load balancer.
resource "aws_security_group_rule" "sg_ingress_rule_ecs_cluster_from_lb" {
  type                     = "ingress"
  description              = "Ingress from Load Balancer"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_security_group.id
  source_security_group_id = aws_security_group.lb_security_group.id
}



# VPC_ENDPOINT for fargate
resource "aws_security_group" "vpce" {
  name   = "vpce"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Environment = "dev"
  }
}



# resource "aws_vpc_endpoint" "dynamo" {
#   vpc_id            = module.vpc.vpc_id
#   service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = module.vpc.private_route_table_ids

#   tags = {
#     Name        = "dynamodb-endpoint"
#     Environment = "dev"
#   }
# }

# resource "aws_vpc_endpoint" "s3" {
#   vpc_id            = module.vpc.vpc_id
#   service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = module.vpc.private_route_table_ids

#   tags = {
#     Name        = "s3-endpoint"
#     Environment = "dev"
#   }
# }

# resource "aws_vpc_endpoint" "dkr" {
#   vpc_id              = module.vpc.vpc_id
#   private_dns_enabled = true
#   service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
#   vpc_endpoint_type   = "Interface"
#   security_group_ids = [
#     aws_security_group.vpce.id,
#   ]
#   subnet_ids = module.vpc.private_subnets

#   tags = {
#     Name        = "dkr-endpoint"
#     Environment = "dev"
#   }
# }


# resource "aws_vpc_endpoint" "api" {
#   vpc_id              = module.vpc.vpc_id
#   private_dns_enabled = true
#   service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
#   vpc_endpoint_type   = "Interface"
#   security_group_ids = [
#     aws_security_group.vpce.id,
#   ]
#   subnet_ids = module.vpc.private_subnets

#   tags = {
#     Name        = "api-endpoint"
#     Environment = "dev"
#   }
# }

# resource "aws_vpc_endpoint" "logs" {
#   vpc_id              = module.vpc.vpc_id
#   private_dns_enabled = true
#   service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
#   vpc_endpoint_type   = "Interface"
#   security_group_ids = [
#     aws_security_group.vpce.id,
#   ]
#   subnet_ids = module.vpc.private_subnets

#   tags = {
#     Name        = "logs-endpoint"
#     Environment = "dev"
#   }
# }

# resource "aws_vpc_endpoint" "ssm" {
#   vpc_id              = module.vpc.vpc_id
#   private_dns_enabled = true
#   service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
#   vpc_endpoint_type   = "Interface"
#   security_group_ids = [
#     aws_security_group.vpce.id,
#   ]
#   subnet_ids = module.vpc.private_subnets

#   tags = {
#     Name        = "ssm-endpoint"
#     Environment = "dev"
#   }
# }