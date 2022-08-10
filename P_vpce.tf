resource "aws_vpc_endpoint" "dynamo" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids

  tags = {
    Name        = "dynamodb-endpoint"
    Environment = "dev"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids

  tags = {
    Name        = "s3-endpoint"
    Environment = "dev"
  }
}

resource "aws_vpc_endpoint" "dkr" {
  vpc_id              = module.vpc.vpc_id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpce.id,
  ]
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name        = "dkr-endpoint"
    Environment = "dev"
  }
}


resource "aws_vpc_endpoint" "api" {
  vpc_id              = module.vpc.vpc_id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpce.id,
  ]
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name        = "api-endpoint"
    Environment = "dev"
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = module.vpc.vpc_id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpce.id,
  ]
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name        = "logs-endpoint"
    Environment = "dev"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = module.vpc.vpc_id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpce.id,
  ]
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name        = "ssm-endpoint"
    Environment = "dev"
  }
}

