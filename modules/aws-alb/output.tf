output "target_group_arn" {
  value = aws_lb_target_group.target_group.arn
}

output "alb_listner" {
  value = aws_lb_listener.listener
}
