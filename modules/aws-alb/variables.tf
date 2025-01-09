variable "tags" {
  type        = map(string)
  description = "(Required) Tags for resources"
}

variable "subnet_ids" {
  type = set(string)
  description = "(Required) Subnet IDs for ALB"
}

variable "container_port" {
  type = number
  description = "Port that needs to be exposed for the application"
}

variable "vpc_id" {
  type = string
  description = "(Required) VPC ID for ALB"
}

variable "acm_certificate_arn" {
  type = string
  description = "Certificate ARN"
}