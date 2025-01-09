output "cluster_id" {
  description = "The ECS cluster ID"
  value = aws_ecs_cluster.default.id
}

output "cloudwatch_group_name" {
  description = "The Cloudwatch group name to store container logs"
  value = aws_cloudwatch_log_group.default.name
}

output "wordpress_admin_password" {
  description = "The Wordpress admin password"
  value     = random_string.wordpress_admin_password.result
  sensitive = true
}