
#######################################################
# Create a Route53 Hosted Zone
#######################################################
resource "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
}

#######################################################
# Create a CNAME Record for Subdomain
#######################################################
resource "aws_route53_record" "subdomain_cname" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "${var.subdomain_name}.${var.domain_name}" # Subdomain (e.g., app.example.com)
  type    = "CNAME"
  ttl     = 300
  records = [var.alb_dns_name] # ALB DNS name
}
