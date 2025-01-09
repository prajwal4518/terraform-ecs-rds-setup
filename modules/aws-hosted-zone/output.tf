output "subdomain" {
  value = aws_route53_record.subdomain_cname.fqdn
}