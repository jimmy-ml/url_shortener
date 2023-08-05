# Cloudfront for S3 bucket short_key
locals {
  s3_website_origin_id = "S3UrlShortenerWebsite"
}

data "aws_cloudfront_cache_policy" "default_cache" {
  name = "Managed-CachingOptimized"
}

# SSM paramaters
data "aws_ssm_parameter" "route_53_main_name" {
  name = "/meli/url-shortener/domain_main/name"
}

data "aws_ssm_parameter" "route_53_main_zone_id" {
  name = "/meli/url-shortener/domain_main/zone_id"
}

data "aws_ssm_parameter" "acm_certificate_main_arn" {
  name = "/meli/url-shortener/acm_certificate_main/arn"
}

# CloudFront
resource "aws_cloudfront_distribution" "url_short_key" {
  enabled         = true
  is_ipv6_enabled = false
  price_class     = "PriceClass_All"
  http_version    = "http2"
  comment         = "CloudFront for Shortener URL"
  aliases         = [data.aws_ssm_parameter.route_53_main_name.value]

  origin {
    origin_id           = local.s3_website_origin_id
    domain_name         = aws_s3_bucket_website_configuration.url_short_key.website_endpoint
    connection_attempts = 3
    connection_timeout  = 10

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "User-Agent"
      value = ".XkSC7a)H(J2B7^BD7H722Wxl:{SeF" # TODO
    }

    origin_shield {
      enabled              = true
      origin_shield_region = data.aws_region.current.id
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_website_origin_id
    cache_policy_id        = data.aws_cloudfront_cache_policy.default_cache.id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.url_short_key_cloudfront_logs.bucket_domain_name
  }

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["RU", "KP", "CN", "IN"]
      # https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_ssm_parameter.acm_certificate_main_arn.value
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  tags = local.common_tags
}

resource "aws_route53_record" "url_short_key" {
  zone_id = data.aws_ssm_parameter.route_53_main_zone_id.value
  name    = data.aws_ssm_parameter.route_53_main_name.value
  type    = "A"
  
  alias {
    name                   = aws_cloudfront_distribution.url_short_key.domain_name
    zone_id                = aws_cloudfront_distribution.url_short_key.hosted_zone_id
    evaluate_target_health = false
  }
}
