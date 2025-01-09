output "wordpress_rds_db_endpoint" {
  value = aws_db_instance.rds_db.endpoint
}

output "wordpress_db_name" {
  value = aws_db_instance.rds_db.db_name
}

output "wordpress_db_port" {
  value = aws_db_instance.rds_db.port
}