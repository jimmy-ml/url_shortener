# DynamoDB short_key
resource "aws_dynamodb_table" "url_short_key" {
  name           = "${local.name_prefix}table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "url_key"

  attribute {
    name = "url_key"
    type = "S"
  }

  attribute {
    name = "target_url"
    type = "S"
  }

  global_secondary_index {
    name            = var.dynamo_short_key_global_index
    hash_key        = "target_url"
    range_key       = "url_key"
    write_capacity  = 1
    read_capacity   = 1
    projection_type = "ALL"
  }

  tags = local.common_tags
}

# SSM paramaters
resource "aws_ssm_parameter" "url_short_key_dynamodb_table_name" {
  name        = "/meli/url-shortener/dynamo-short-key/name"
  description = "DynamoDB table name for URL shortener"
  type        = "String"
  value       = aws_dynamodb_table.url_short_key.id
  tags        = local.common_tags
}

resource "aws_ssm_parameter" "url_short_key_dynamodb_table_arn" {
  name        = "/meli/url-shortener/dynamo-short-key/arn"
  description = "DynamoDB table ARN for URL shortener"
  type        = "String"
  value       = aws_dynamodb_table.url_short_key.arn
  tags        = local.common_tags
}

resource "aws_ssm_parameter" "url_short_key_dynamodb_global_index_name" {
  name        = "/meli/url-shortener/dynamo-short-key/global-index/name"
  description = "Global Secondary Index name for URL shortener"
  type        = "String"
  value       = var.dynamo_short_key_global_index
  tags        = local.common_tags
}
