# DynamoDB short_key
variable "dynamo_short_key_global_index" {
  description = "Global secondary index name for short_key dynamo table"
  type        = string
  default     = "target_url_index"
}
