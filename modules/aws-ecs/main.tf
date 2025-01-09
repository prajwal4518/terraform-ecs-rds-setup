resource "aws_ecs_cluster" "default" {
  name = "${local.ecs_name}-ecs-cluster"
  tags = merge({
    name = "${local.ecs_name}-ecs-cluster"
  }, var.tags)
}

resource "aws_cloudwatch_log_group" "default" {
  name = "${local.ecs_name}-ecs-cloudwatch-log-group"
  tags = merge({
    name = "${local.ecs_name}-ecs-cloudwatch-log-group"
  }, var.tags)
}

#################################################################################################
# Below code describes the IAM resources: ECS task role, ECS execution role
#################################################################################################


data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${local.ecs_name}-ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecsTaskRole" {
  name               = "${local.ecs_name}-ecsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskRole_policy" {
  role       = aws_iam_role.ecsTaskRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_security_group" "ecs_tasks" {
  name        = "wordpress-ecs-sg"
  description = "Allow inbound access in port 80 only"
  vpc_id      = var.vpc_id

  ingress {
    protocol  = "tcp"
    from_port = var.wordpress_port
    to_port   = var.wordpress_port
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  egress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  tags = merge({
    name = "${local.ecs_name}-ecs-sg"
  }, var.tags)
}

resource "random_string" "wordpress_admin_password" {
  length = 16
}


resource "aws_ecs_task_definition" "task" {
  family       = "wordpress"
  network_mode = "awsvpc"
  requires_compatibilities = [
  "FARGATE"]
  cpu                = var.fargate_cpu
  memory             = var.fargate_memory
  task_role_arn      = aws_iam_role.ecsTaskRole.arn
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = jsonencode([
    {
      name      = "${local.ecs_name}-ecs-container"
      essential = true
      image     = "wordpress"
      environment = [
        {
          name  = "WP_DB_WAIT_TIME"
          value = "1"
        },
        {
          name  = "WP_VERSION"
          value = var.wordpress_version
        },
        {
          name  = "TZ"
          value = var.wordpress_timezone
        },
        {
          name  = "WP_DB_HOST"
          value = var.wordpress_db_host
        },
        {
          name  = "WP_DB_NAME"
          value = var.wordpress_db_name
        },
        {
          name  = "WP_DB_USER"
          value = var.wordpress_db_user
        },
        {
          name  = "MYSQL_ENV_MYSQL_PASSWORD"
          value = var.wordpress_db_password
        },
        {
          name  = "WP_DOMAIN"
          value = var.wordpress_domain
        },
        {
          name  = "WP_URL"
          value = var.wordpress_url
        },
        {
          name  = "WP_LOCALE",
          value = var.wordpress_locale
        },
        {
          name  = "WP_SITE_TITLE"
          value = var.wordpress_site_title
        },
        {
          name  = "WP_ADMIN_USER"
          value = var.wordpress_admin_user
        },
        {
          name  = "WP_ADMIN_PASSWORD"
          value = random_string.wordpress_admin_password.result
        },
        {
          name  = "WP_ADMIN_EMAIL"
          value = var.wordpress_admin_email
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.default.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      },
      portMappings = [
        {
          hostPort      = var.wordpress_port
          containerPort = var.wordpress_port
          protocol      = "TCP"
        }
      ]
    }
  ])

  tags = merge({
    name = "${local.ecs_name}-ecs-task"
  }, var.tags)
}

resource "aws_ecs_service" "default" {
  name            = "${local.ecs_name}-ecs-service"
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [
    aws_security_group.ecs_tasks.id]
    subnets          = var.subnet_id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "${local.ecs_name}-ecs-container"
    container_port   = var.container_port
  }
  depends_on = [var.alb_listner]

  tags = merge({
    name = "${local.ecs_name}-ecs-service"
  }, var.tags)
}
