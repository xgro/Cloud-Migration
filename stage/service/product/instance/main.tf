data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = var.config
}

# AWS_cloudwatch 활성화
resource "aws_cloudwatch_log_group" "app" {
  name = "/ecs/app"
  tags = {
    Environment = "dev"
  }
}


# Create the ECS Cluster and Fargate launch type service in the private subnets
resource "aws_ecs_cluster" "ecs_cluster" {
  name       = "ecs-cluster"

  configuration {
    execute_command_configuration {
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.app.name
      }
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.app
  ]
}

resource "aws_ecs_service" "ecs-service" {
  name                               = "ecs-svc"
  cluster                            = aws_ecs_cluster.ecs_cluster.id
  task_definition                    = aws_ecs_task_definition.ecs_taskdef.arn
  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  enable_ecs_managed_tags            = false
  health_check_grace_period_seconds  = 30
  launch_type                        = "FARGATE"
  depends_on                         = [
    aws_lb_target_group.alb_ecs_tg, 
    aws_lb_listener.ecs_alb_listener
  ]

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_ecs_tg.arn
    container_name   = "product"
    container_port   = 80
  }

  network_configuration {
    security_groups = [data.terraform_remote_state.vpc.outputs.ecs-security_group_id]
    subnets         = data.terraform_remote_state.vpc.outputs.private_subnets
  }
}

# Create the ECS Service task definition. 
# 'nginx' image is being used in the container definition.
# This image is pulled from the docker hub which is the default image repository.
# ECS task execution role and the task role is used which can be attached with additional IAM policies to configure the required permissions.
resource "aws_ecs_task_definition" "ecs_taskdef" {
  family = "service"
  container_definitions = jsonencode([
    {
      name      = "product"
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/stock-management-api:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      secrets = [
        {
          valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.secrets}",
          name      = "${var.secrets}"
        }
      ]
    }
  ])
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_exec_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
}


# Create the internal application load balancer (ALB) in the private subnets.
resource "aws_lb" "ecs_alb" {
  load_balancer_type = "application"
  internal           = true
  subnets            = data.terraform_remote_state.vpc.outputs.private_subnets
  security_groups    = [
    data.terraform_remote_state.vpc.outputs.lb-security_group_id
  ]
}

# Create the ALB target group for ECS.
resource "aws_lb_target_group" "alb_ecs_tg" {
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
}

# Create the ALB listener with the target group.
resource "aws_lb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_ecs_tg.arn
  }
}


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
        "Resource": "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${var.ecr_name}"
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


# DynamoDB 접근 권한
data "aws_iam_policy" "DynamoDBFullAccess" {
  name = "AmazonDynamoDBFullAccess"
}

# 기존 정책에 aws_iam_policy 정책 추가
resource "aws_iam_role_policy_attachment" "fargate-task-dynamodb" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = data.aws_iam_policy.DynamoDBFullAccess.arn
}


