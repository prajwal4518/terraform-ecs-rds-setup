variable "domain_name" {
  description = "The domain name to configure Route53 hosted zone."
  type        = string
}

variable "subdomain_name" {
  description = "Subdomain name to route traffic to ALB."
  type        = string
  default     = "app" # Default subdomain is "app"
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB."
  type        = string
}