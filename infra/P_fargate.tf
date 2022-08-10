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
    security_groups = [aws_security_group.ecs_security_group.id]
    subnets         = module.vpc.private_subnets
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

