# Create the API Gateway HTTP endpoint
resource "aws_apigatewayv2_api" "apigw_http_endpoint" {
  name          = "accompany-endpoint"
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
  domain_name = "api.xgro.be"

  domain_name_configuration {
    certificate_arn = data.aws_acm_certificate.issued.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

# 권한 부여자 생성 
resource "aws_apigatewayv2_authorizer" "authorizer" {
  api_id                            = aws_apigatewayv2_api.apigw_http_endpoint.id
  authorizer_type                   = "REQUEST"
  name                              = "lambda_authorizer"
  authorizer_payload_format_version = "2.0"
  authorizer_uri                    = module.lambda.lambda_function_invoke_arn
  authorizer_credentials_arn        = aws_iam_role.invocation_role.arn
  identity_sources                  = ["$request.header.Authorization"]
}

# API GW route with ANY method /product/{proxy+}
resource "aws_apigatewayv2_route" "apigw_route" {
  api_id             = aws_apigatewayv2_api.apigw_http_endpoint.id
  route_key          = "ANY /product/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.apigw_integration.id}"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.authorizer.id
  depends_on = [
    aws_apigatewayv2_integration.apigw_integration,
    aws_apigatewayv2_authorizer.authorizer
  ]
}

# Create the VPC Link configured with the private subnets. Security groups are kept empty here, but can be configured as required.
resource "aws_apigatewayv2_vpc_link" "vpclink_apigw_to_alb" {
  name               = "vpclink_apigw_to_alb"
  security_group_ids = []
  subnet_ids         = module.vpc.private_subnets
}

# Create the API Gateway HTTP_PROXY integration between the created API and the private load balancer via the VPC Link.
# Ensure that the 'DependsOn' attribute has the VPC Link dependency.
# This is to ensure that the VPC Link is created successfully before the integration and the API GW routes are created.
resource "aws_apigatewayv2_integration" "apigw_integration" {
  api_id           = aws_apigatewayv2_api.apigw_http_endpoint.id
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_lb_listener.ecs_alb_listener.arn

  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpclink_apigw_to_alb.id
  depends_on = [
    aws_apigatewayv2_vpc_link.vpclink_apigw_to_alb,
    aws_apigatewayv2_api.apigw_http_endpoint,
    aws_lb_listener.ecs_alb_listener
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
    aws_apigatewayv2_integration.apigw_integration_ec2,
  ]
}

# Create the VPC Link configured with the private subnets. Security groups are kept empty here, but can be configured as required.
resource "aws_apigatewayv2_vpc_link" "vpclink_apigw_to_ec2" {
  name               = "vpclink_apigw_to_ec2"
  security_group_ids = [aws_security_group.monolitic_security_group.id]
  subnet_ids         = module.vpc_mono.private_subnets
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
