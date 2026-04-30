# Get current AWS region for CloudWatch logs
data "aws_region" "current" {}

resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge({
    Name        = var.ecs_cluster_name
    Environment = lookup(var.tags, "Environment", "development")
    Namespace   = lookup(var.tags, "Namespace", "development")
  }, var.tags)
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.ecs_task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = var.ecs_container_name
      image = var.ecs_container_image

      portMappings = [
        {
          containerPort = var.ecs_container_port
          hostPort      = var.ecs_container_port
          protocol      = "tcp"
        }
      ]

      environment = var.ecs_environment_variables

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${lookup(var.tags, "Environment", "development")}/${var.ecs_task_family}"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }

      essential = true
    }
  ])

  tags = merge({
    Name        = var.ecs_task_family
    Environment = lookup(var.tags, "Environment", "development")
    Namespace   = lookup(var.tags, "Namespace", "development")
  }, var.tags)
}

resource "aws_ecs_service" "app" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.ecs_security_group_id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.ecs_container_name
    container_port   = var.ecs_container_port
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_execution_role_policy]

  tags = merge({
    Name        = var.ecs_service_name
    Environment = lookup(var.tags, "Environment", "development")
    Namespace   = lookup(var.tags, "Namespace", "development")
  }, var.tags)
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.ecs_cluster_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge({
    Name        = "${var.ecs_cluster_name}-execution-role"
    Environment = lookup(var.tags, "Environment", "development")
    Namespace   = lookup(var.tags, "Namespace", "development")
  }, var.tags)
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.ecs_cluster_name}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge({
    Name        = "${var.ecs_cluster_name}-task-role"
    Environment = lookup(var.tags, "Environment", "development")
    Namespace   = lookup(var.tags, "Namespace", "development")
  }, var.tags)
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${lookup(var.tags, "Environment", "development")}/${var.ecs_task_family}"
  retention_in_days = 30

  tags = merge({
    Name        = var.ecs_task_family
    Environment = lookup(var.tags, "Environment", "development")
    Namespace   = lookup(var.tags, "Namespace", "development")
  }, var.tags)
}
