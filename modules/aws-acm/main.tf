#######################################################
# Step 1: Create ACM Certificate
#######################################################
resource "aws_acm_certificate" "my_public_cert" {
  domain_name               = "www.${var.domain_name}"   # Main domain
  subject_alternative_names = ["*.${var.domain_name}"]   # Wildcard for subdomains
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

#######################################################
# Step 2: DNS Validation with Route53
#######################################################
data "aws_route53_zone" "selected_zone" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.my_public_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected_zone.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.my_public_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

