# fargate-role에 대한 정책 불러오기
data "aws_iam_policy_document" "fargate-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }
}

# fargate 실행 역할에 대한 정책 생성
resource "aws_iam_policy" "fargate_execution" {
  name   = "fargate_execution_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [  
    {
        "Effect": "Allow",
        "Action": [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability"
        ],
        "Resource": "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${var.ECR_repo}"
    },
    {
        "Effect": "Allow",
        "Action": [
            "ecr:GetAuthorizationToken"
        ],
        "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# fargate ssm 접근 권한 정책 생성
resource "aws_iam_policy" "fargate_ssm" {
  name   = "fargate_ssm_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [  
    {
        "Action": [
            "ssm:GetParameters"
        ],
        "Effect": "Allow",
        "Resource": [
            "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.secrets}"
        ]
    }
  ]
}
EOF
}


# 태스크 정책 생성 
# cloudwatch_log 
resource "aws_iam_policy" "fargate_task" {
  name   = "fargate_task_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [  
    {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "*"
    }
  ]
}
EOF
}



resource "aws_iam_role" "ecs_task_exec_role" {
  name               = "fargate_execution_role"
  assume_role_policy = data.aws_iam_policy_document.fargate-role-policy.json
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "fargate_task_role"
  assume_role_policy = data.aws_iam_policy_document.fargate-role-policy.json
}

resource "aws_iam_role_policy_attachment" "fargate-execution" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = aws_iam_policy.fargate_execution.arn
}

resource "aws_iam_role_policy_attachment" "fargate-execution-ssm" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = aws_iam_policy.fargate_ssm.arn
}

resource "aws_iam_role_policy_attachment" "fargate-task" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.fargate_task.arn
}

data "aws_iam_policy" "DynamoDBFullAccess" {
  name = "AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "fargate-task-dynamodb" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = data.aws_iam_policy.DynamoDBFullAccess.arn
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
      "Resource": "${module.lambda.lambda_function_arn}"
    }
  ]
}
EOF
}