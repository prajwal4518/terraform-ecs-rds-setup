terraform {
  required_version = "> 0.15.0"
  backend "s3" {
    bucket = "cloudzania-terraform-states"
    key    = "dev/rds.tf"
    region = "us-east-1"
  }
}



module "vpc" {
  source             = "../../modules/aws-vpc"
  app-name           = "cloudzania"
  region             = "us-east-1"
  availability_zones = ["us-east-1a", "us-east-1b"]
}

module "SecretsManager" {
  source       = "../../modules/aws-secret-manager"
  rds_password = "admin123456789"
  rds_username = "admin"
}

data "aws_secretsmanager_secret" "db_secrets" {
  arn = module.SecretsManager.secret_arn
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.db_secrets.id
}

module "rds" {
  source                  = "../../modules/aws-rds"
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_subnet_ids
  db_subnet_group_name    = module.vpc.private_subnet_ids[0]
  region                  = "us-east-1"
  db_port                 = 3306
  db_name                 = "wordpress"
  db_allocated_storage    = 10
  db_instance_class       = "db.t3.micro"
  db_storage_type         = "gp2"
  db_username             = jsondecode(nonsensitive(data.aws_secretsmanager_secret_version.current.secret_string))["username"]
  db_password             = jsondecode(nonsensitive(data.aws_secretsmanager_secret_version.current.secret_string))["password"]
  db_engine               = "mysql"
  db_engine_version       = "5.7"
  db_parameter_group_name = "default.mysql5.7"
  db_skip_final_snapshot  = true
  tags = {
    environment = "dev"
    project     = "ecs-wordpress"
    terraform   = true
  }
}

module "acm_certificate_arn" {
  source = "../../modules/aws-acm"
  domain_name = "duckdns.org"
}

module "application_load_balancer" {

  source         = "../../modules/aws-alb"
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.public_subnet_ids
  container_port = 80
  acm_certificate_arn = module.acm_certificate_arn.certificate_arn
  tags = {
    environment = "dev"
    project     = "cloudzania"
    terraform   = true
  }
}

module "wordpressECS" {
  source                = "../../modules/aws-ecs"
  vpc_id                = module.vpc.vpc_id
  subnet_id             = module.vpc.private_subnet_ids
  wordpress_db_host     = module.rds.wordpress_rds_db_endpoint
  wordpress_db_name     = module.rds.wordpress_db_name
  wordpress_db_password = jsondecode(nonsensitive(data.aws_secretsmanager_secret_version.current.secret_string))["password"]
  wordpress_db_user     = jsondecode(nonsensitive(data.aws_secretsmanager_secret_version.current.secret_string))["username"]
  wordpress_db_port     = module.rds.wordpress_db_port
  region                = "us-east-1"
  desired_count         = 1
  fargate_cpu           = 256
  fargate_memory        = 512
  wordpress_port        = 80
  container_port        = 80
  target_group_arn      = module.application_load_balancer.target_group_arn
  alb_listner           = module.application_load_balancer.alb_listner
  tags = {
    environment = "dev"
    project     = "cloudzania"
    terraform   = true
  }

}

output "wordpress_admin_password" {
  description = "The Wordpress admin password"
  value       = module.wordpressECS.wordpress_admin_password
  sensitive   = false
}

output "db_name" {
  value = module.rds.wordpress_db_name
}

output "wordpress_rds_db_endpoint" {
  value = module.rds.wordpress_rds_db_endpoint
}


