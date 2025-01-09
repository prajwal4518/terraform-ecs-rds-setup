variable "rds_username" {
  description = "Database username for SecretsManager"
  type        = string
}

variable "rds_password" {
  description = "Database password for SecretsManager"
  type        = string
  sensitive   = true
}