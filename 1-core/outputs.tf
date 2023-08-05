# S3 bucket short_key
output "url_short_key_bucket_name" {
  description = "Bucket name for URL shortener"
  value       = aws_s3_bucket.url_short_key.id
}

output "url_short_key_bucket_arn" {
  description = "Bucket ARN for URL shortener"
  value       = aws_s3_bucket.url_short_key.arn
}

output "url_short_key_bucket_website_url" {
  description = "Website endpoint of Bucket for URL shortener"
  value       = aws_s3_bucket_website_configuration.url_short_key.website_endpoint
}

# S3 bucket short_key_cloudfront_logs
output "url_short_key_cloudfront_logs_name" {
  description = "Bucket name for Cloudfront Logs of URL shortener"
  value       = aws_s3_bucket.url_short_key_cloudfront_logs.id
}

output "url_short_key_cloudfront_logs_arn" {
  description = "Bucket ARN for Cloudfront Logs of URL shortener"
  value       = aws_s3_bucket.url_short_key_cloudfront_logs.arn
}

# DynamoDB table short_key
output "url_short_key_dynamodb_table_name" {
  description = "DynamoDB table name for URL shortener"
  value       = aws_dynamodb_table.url_short_key.id
}

output "url_short_key_dynamodb_table_arn" {
  description = "DynamoDB table ARN for URL shortener"
  value       = aws_dynamodb_table.url_short_key.arn
}

output "url_short_key_dynamodb_global_index_name" {
  description = "Global Secondary Index name for URL shortener"
  value       = var.dynamo_short_key_global_index
}
