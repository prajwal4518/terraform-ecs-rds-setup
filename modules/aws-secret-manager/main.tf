resource "random_string" "random_string" {
  length  = 6
  special = false
}
resource "aws_secretsmanager_secret" "rds_cred5" {
  name = "rds_cred-${random_string.random_string.result}"
}

resource "aws_secretsmanager_secret_version" "rds_cred5_version" {
  secret_id = aws_secretsmanager_secret.rds_cred5.id
  secret_string = jsonencode({
    username = var.rds_username,
    password = var.rds_password
  })
}

output "secret_arn" {
  description = "SecretsManager ARN for RDS credentials"
  value       = aws_secretsmanager_secret.rds_cred5.arn
}
