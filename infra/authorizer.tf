# Lambda 선언
module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "3.3.1"
  # insert the 32 required variables here
  function_name = "authorizer"
  description   = "My awesome lambda function"
  handler       = "app.handler"
  runtime       = "nodejs14.x"
  timeout       = 6

  environment_variables =  {
    JWT_SECRET = data.aws_ssm_parameter.ssm.value
  }

  source_path                   = "./authorizer"
  attach_cloudwatch_logs_policy = true

  tags = {
    Name = "authorizer_lambda"
  }
}

data "aws_ssm_parameter" "ssm" {
  name = "JWT_SECRET"
}

# 람다 트리거 연결하는 리소스
# Attach API Gateway to Lambda 
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.apigw_http_endpoint.execution_arn}/authorizers/${aws_apigatewayv2_authorizer.authorizer.id}"
}

