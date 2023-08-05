# Route53 Hosted Zone
resource "aws_route53_zone" "main" {
  name = var.route53_zone_name

  tags = local.common_tags
}

###############################################################################
# ACM certificate for main domain
resource "aws_acm_certificate" "main" {
  domain_name       = var.route53_zone_name
  validation_method = "DNS"

  tags = local.common_tags
}

# ACM records in main domain
resource "aws_route53_record" "main" {
  for_each = {
    for acm in aws_acm_certificate.main.domain_validation_options : acm.domain_name => {
      name   = acm.resource_record_name
      record = acm.resource_record_value
      type   = acm.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

# ACM validation
resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.main : record.fqdn]
}

###############################################################################
# ACM certificate for api
resource "aws_acm_certificate" "api" {
  domain_name       = "api.${var.route53_zone_name}"
  validation_method = "DNS"

  tags = local.common_tags
}

# ACM records in main domain
resource "aws_route53_record" "api" {
  for_each = {
    for acm in aws_acm_certificate.api.domain_validation_options : acm.domain_name => {
      name   = acm.resource_record_name
      record = acm.resource_record_value
      type   = acm.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

# ACM validation
resource "aws_acm_certificate_validation" "api" {
  certificate_arn         = aws_acm_certificate.api.arn
  validation_record_fqdns = [for record in aws_route53_record.api : record.fqdn]
}

###############################################################################
# SSM paramaters
resource "aws_ssm_parameter" "route_53_main_name" {
  name        = "/meli/url-shortener/domain_main/name"
  description = "Name of the domain for URL shortener"
  type        = "String"
  value       = aws_route53_zone.main.name
  tags        = local.common_tags
}

resource "aws_ssm_parameter" "route_53_main_zone_id" {
  name        = "/meli/url-shortener/domain_main/zone_id"
  description = "Zone ID of the domain for URL shortener"
  type        = "String"
  value       = aws_route53_zone.main.zone_id
  tags        = local.common_tags
}

resource "aws_ssm_parameter" "acm_certificate_main_arn" {
  name        = "/meli/url-shortener/acm_certificate_main/arn"
  description = "ARN of the ACM Certificate for URL shortener"
  type        = "String"
  value       = aws_acm_certificate.main.arn
  tags        = local.common_tags
}

resource "aws_ssm_parameter" "acm_certificate_api_arn" {
  name        = "/meli/url-shortener/acm_certificate_api/arn"
  description = "ARN of the ACM Certificate for API URL shortener"
  type        = "String"
  value       = aws_acm_certificate.api.arn
  tags        = local.common_tags
}
