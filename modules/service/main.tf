resource "aws_alb_target_group" "this" {
  name_prefix = "certi-"
  port        = var.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  slow_start  = 60

  health_check {
    path = var.healthcheck
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/astrosat/${var.name}"
  retention_in_days = 5
}

resource "aws_alb_listener" "main" {
  load_balancer_arn = var.lb_arn
  port              = var.lb_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.https_certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.this.id
    type             = "forward"
  }
}


resource "aws_ssm_parameter" "secrets" {
  for_each = { for secret in var.secrets : secret.key => secret }
  name     = "/astrosat/${var.name}/${each.value.key}"
  type     = each.value.secure ? "SecureString" : "String"
  value    = each.value.value
}

locals {
  taskSecrets = [for secret in values(aws_ssm_parameter.secrets) : {
    "name" : substr(secret.name, length("/astrosat/${var.name}/"), -1)
    "valueFrom" : secret.arn
  }]
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.this.arn
  task_role_arn            = aws_iam_role.this.arn
  container_definitions    = <<DEFINITION
[
  {
    "name" : "${var.name}",
    "cpu": ${var.cpu},
    "image": "${var.image}:${var.image_tag}",
    "memory": ${var.memory},
    "networkMode": "awsvpc",
    "linuxParameters": {
                "initProcessEnabled": true
    },
    "portMappings": [
      {
        "containerPort": ${var.port}
      }
    ],
    "secrets" : ${jsonencode(local.taskSecrets)},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group":"/astrosat/${var.name}",
        "awslogs-region": "ap-south-1",
        "awslogs-stream-prefix": "LOG"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_service" "main" {
  name                   = var.name
  cluster                = var.cluster_arn
  task_definition        = aws_ecs_task_definition.this.arn
  desired_count          = var.desired_count
  enable_execute_command = true

  network_configuration {
    security_groups  = [aws_security_group.this.id]
    subnets          = var.private_subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.this.id
    container_name   = var.name
    container_port   = var.port
  }


  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
    base              = 0
  }
}
