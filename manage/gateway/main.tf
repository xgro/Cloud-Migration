data "terraform_remote_state" "monolithic" {
  backend = "s3"

  config = var.config_monolithic
}

data "terraform_remote_state" "product" {
  backend = "s3"

  config = var.config_product
}

data "terraform_remote_state" "vpc_monolithic" {
  backend = "s3"

  config = var.config_monolithic_vpc
}

data "terraform_remote_state" "vpc_product" {
  backend = "s3"

  config = var.config_product_vpc
}


# Create the API Gateway HTTP endpoint
resource "aws_apigatewayv2_api" "apigw_http_endpoint" {
  name          = var.api_gateway_name
  protocol_type = "HTTP"
}

# Set a default stage
resource "aws_apigatewayv2_stage" "apigw_stage" {
  api_id      = aws_apigatewayv2_api.apigw_http_endpoint.id
  name        = "$default"
  auto_deploy = true
  depends_on  = [
    aws_apigatewayv2_api.apigw_http_endpoint
  ]
}


resource "aws_apigatewayv2_api_mapping" "domain" {
  api_id      = aws_apigatewayv2_api.apigw_http_endpoint.id
  domain_name = aws_apigatewayv2_domain_name.domain.id
  stage       = aws_apigatewayv2_stage.apigw_stage.id
}


resource "aws_apigatewayv2_domain_name" "domain" {
  domain_name = var.domain

  domain_name_configuration {
    certificate_arn = data.aws_acm_certificate.issued.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

# 권한 부여자 생성 
resource "aws_apigatewayv2_authorizer" "this" {
  api_id                            = aws_apigatewayv2_api.apigw_http_endpoint.id
  authorizer_type                   = "REQUEST"
  name                              = "lambda_authorizer"
  authorizer_payload_format_version = "2.0"
  authorizer_uri                    = data.aws_lambda_function.existing.invoke_arn
  authorizer_credentials_arn        = aws_iam_role.invocation_role.arn
  identity_sources                  = ["$request.header.Authorization"]
}




# API GW route with ANY method /product/{proxy+}
resource "aws_apigatewayv2_route" "apigw_route" {
  api_id             = aws_apigatewayv2_api.apigw_http_endpoint.id
  route_key          = "ANY /product/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.apigw_integration.id}"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.this.id
  depends_on = [
    aws_apigatewayv2_integration.apigw_integration,
    aws_apigatewayv2_authorizer.this
  ]
}

# Create the VPC Link configured with the private subnets. Security groups are kept empty here, but can be configured as required.
resource "aws_apigatewayv2_vpc_link" "vpclink_apigw_to_alb" {
  name               = "vpclink_apigw_to_alb"
  security_group_ids = []
  subnet_ids         = data.terraform_remote_state.vpc_product.outputs.private_subnets
}

# Create the API Gateway HTTP_PROXY integration between the created API and the private load balancer via the VPC Link.
# Ensure that the 'DependsOn' attribute has the VPC Link dependency.
# This is to ensure that the VPC Link is created successfully before the integration and the API GW routes are created.
resource "aws_apigatewayv2_integration" "apigw_integration" {
  api_id           = aws_apigatewayv2_api.apigw_http_endpoint.id
  integration_type = "HTTP_PROXY"
  integration_uri  = data.terraform_remote_state.product.outputs.ecs_alb_listener

  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpclink_apigw_to_alb.id
  depends_on = [
    aws_apigatewayv2_vpc_link.vpclink_apigw_to_alb,
    aws_apigatewayv2_api.apigw_http_endpoint,
    # aws_lb_listener.ecs_alb_listener
  ]
}


###########################################
###########################################
# API GW route with ANY method
resource "aws_apigatewayv2_route" "apigw_route_ec2" {
  api_id    = aws_apigatewayv2_api.apigw_http_endpoint.id
  route_key = "ANY /user/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.apigw_integration_ec2.id}"

  depends_on = [
    aws_apigatewayv2_integration.apigw_integration_ec2
  ]
}

# Create the VPC Link configured with the private subnets. Security groups are kept empty here, but can be configured as required.
resource "aws_apigatewayv2_vpc_link" "vpclink_apigw_to_ec2" {
  name               = "vpclink_apigw_to_ec2"
  security_group_ids = [data.terraform_remote_state.vpc_monolithic.outputs.monolithic-security_group_id]
  subnet_ids         = data.terraform_remote_state.vpc_monolithic.outputs.private_subnets
}

# Create the API Gateway HTTP_PROXY integration between the created API and the private load balancer via the VPC Link.
# Ensure that the 'DependsOn' attribute has the VPC Link dependency.
# This is to ensure that the VPC Link is created successfully before the integration and the API GW routes are created.
resource "aws_apigatewayv2_integration" "apigw_integration_ec2" {
  api_id           = aws_apigatewayv2_api.apigw_http_endpoint.id
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_service_discovery_service.shared.arn

  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpclink_apigw_to_ec2.id

  depends_on = [
    aws_apigatewayv2_vpc_link.vpclink_apigw_to_ec2,
    aws_apigatewayv2_api.apigw_http_endpoint,
    aws_service_discovery_service.shared
  ]
}


# CLOUDMAP
resource "aws_service_discovery_private_dns_namespace" "private" {
  name = "private"
  vpc  = data.terraform_remote_state.vpc_monolithic.outputs.vpc_id
}

resource "aws_service_discovery_service" "shared" {
  name = "shared"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private.id

    dns_records {
      ttl  = 300
      type = "A"
    }

    routing_policy = "WEIGHTED"
  }
}

resource "aws_service_discovery_instance" "ec2" {
  instance_id = "monolithic-instance"
  service_id  = aws_service_discovery_service.shared.id

  attributes = {
    AWS_INSTANCE_IPV4 = data.terraform_remote_state.monolithic.outputs.ec2_private_ip
    AWS_INSTANCE_PORT = 80
    custom_attribute  = "custom"
  }
}


resource "aws_route53_record" "this" {
  name    = aws_apigatewayv2_domain_name.domain.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.selected.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

data "aws_route53_zone" "selected" {
  name         = var.domain
  # private_zone = true
}

data "aws_acm_certificate" "issued" {
  domain   = "api.${var.domain}"
  statuses = ["ISSUED"]
}


resource "aws_iam_role" "invocation_role" {
  name = "api_gateway_auth_invocation"
  path = "/product/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "invocation_policy" {
  name = "default"
  role = aws_iam_role.invocation_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${data.aws_lambda_function.existing.arn}"
    }
  ]
}
EOF
}


data "aws_lambda_function" "existing" {
  function_name = var.function_name
}

