###############################################################################
# S3 bucket short_key
resource "aws_s3_bucket" "url_short_key" {
  bucket_prefix = local.name_prefix
  tags          = local.common_tags
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "url_short_key" {
  bucket = aws_s3_bucket.url_short_key.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 bucket website configuration
resource "aws_s3_bucket_website_configuration" "url_short_key" {
  bucket = aws_s3_bucket.url_short_key.id

  index_document {
    suffix = "index.html"
  }
}

# S3 bucket policy
data "aws_iam_policy_document" "allow_public_access_with_header" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.url_short_key.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:UserAgent"
      values   = [".XkSC7a)H(J2B7^BD7H722Wxl:{SeF"] # TODO
    }
  }
}

resource "aws_s3_bucket_policy" "allow_public_access_with_header" {
  bucket = aws_s3_bucket.url_short_key.id
  policy = data.aws_iam_policy_document.allow_public_access_with_header.json
}

# SSM paramaters
resource "aws_ssm_parameter" "url_short_key_bucket_name" {
  name        = "/meli/url-shortener/bucket-short-key/name"
  description = "Bucket name for URL shortener"
  type        = "String"
  value       = aws_s3_bucket.url_short_key.id
  tags        = local.common_tags
}

resource "aws_ssm_parameter" "url_short_key_bucket_arn" {
  name        = "/meli/url-shortener/bucket-short-key/arn"
  description = "Bucket ARN for URL shortener"
  type        = "String"
  value       = aws_s3_bucket.url_short_key.arn
  tags        = local.common_tags
}

resource "aws_ssm_parameter" "url_short_key_bucket_website_url" {
  name        = "/meli/url-shortener/bucket-short-key/website-endpoint"
  description = "Website endpoint of Bucket for URL shortener"
  type        = "String"
  value       = aws_s3_bucket_website_configuration.url_short_key.website_endpoint
  tags        = local.common_tags
}

###############################################################################
# S3 bucket short_key_cloudfront_logs
resource "aws_s3_bucket" "url_short_key_cloudfront_logs" {
  bucket_prefix = "${local.name_prefix}logs-"
  tags          = local.common_tags
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "url_short_key_cloudfront_logs" {
  bucket = aws_s3_bucket.url_short_key_cloudfront_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 ownership controls
resource "aws_s3_bucket_ownership_controls" "url_short_key_cloudfront_logs" {
  bucket = aws_s3_bucket.url_short_key_cloudfront_logs.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

# S3 lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "url_short_key_cloudfront_logs" {
  bucket = aws_s3_bucket.url_short_key_cloudfront_logs.id

  rule {
    id = "Delete7Days"
    status = "Enabled"

    # Delete objects older 7 days
    expiration {
      days = 7
    }
  }
}

# SSM paramaters
resource "aws_ssm_parameter" "url_short_key_cloudfront_logs_name" {
  name        = "/meli/url-shortener/bucket-short-key-cloudfront-logs/name"
  description = "Bucket name for Cloudfront Logs of URL shortener"
  type        = "String"
  value       = aws_s3_bucket.url_short_key_cloudfront_logs.id
  tags        = local.common_tags
}

resource "aws_ssm_parameter" "url_short_key_cloudfront_logs_arn" {
  name        = "/meli/url-shortener/bucket-short-key-cloudfront-logs/arn"
  description = "Bucket ARN for Cloudfront Logs of URL shortener"
  type        = "String"
  value       = aws_s3_bucket.url_short_key_cloudfront_logs.arn
  tags        = local.common_tags
}
