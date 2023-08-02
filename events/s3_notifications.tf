###############################################################################
# S3 notification trigger for bucket short_key

# SSM paramaters
data "aws_ssm_parameter" "url_short_key_bucket_name" {
  name = "/meli/url-shortener/bucket-short-key/name"
}

data "aws_ssm_parameter" "url_short_key_bucket_arn" {
  name = "/meli/url-shortener/bucket-short-key/arn"
}

data "aws_ssm_parameter" "function_put_item_dynamo_arn" {
  name = "/meli/url-shortener/sam-api/lambda/put-item-dynamo/arn"
}

data "aws_ssm_parameter" "function_delete_item_dynamo_arn" {
  name = "/meli/url-shortener/sam-api/lambda/delete-item-dynamo/arn"
}

resource "aws_lambda_permission" "s3_invoke_put_dynamo" {
  action        = "lambda:InvokeFunction"
  function_name = data.aws_ssm_parameter.function_put_item_dynamo_arn.value
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_ssm_parameter.url_short_key_bucket_arn.value
}

resource "aws_lambda_permission" "s3_invoke_delete_dynamo" {
  action        = "lambda:InvokeFunction"
  function_name = data.aws_ssm_parameter.function_delete_item_dynamo_arn.value
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_ssm_parameter.url_short_key_bucket_arn.value
}

resource "aws_s3_bucket_notification" "url_short_key_bucket_notification" {
  bucket = data.aws_ssm_parameter.url_short_key_bucket_name.value

  lambda_function {
    lambda_function_arn = data.aws_ssm_parameter.function_put_item_dynamo_arn.value
    events              = ["s3:ObjectCreated:Put"]
  }

  lambda_function {
    lambda_function_arn = data.aws_ssm_parameter.function_delete_item_dynamo_arn.value
    events              = ["s3:ObjectRemoved:Delete"]
  }

  depends_on = [
    aws_lambda_permission.s3_invoke_put_dynamo,
    aws_lambda_permission.s3_invoke_delete_dynamo,
  ]
}

###############################################################################
# S3 notification trigger for bucket cloudfront_logs

# SSM paramaters
data "aws_ssm_parameter" "url_cloudfront_logs_bucket_name" {
  name = "/meli/url-shortener/bucket-short-key-cloudfront-logs/name"
}

data "aws_ssm_parameter" "url_cloudfront_logs_bucket_name_arn" {
  name = "/meli/url-shortener/bucket-short-key-cloudfront-logs/arn"
}

data "aws_ssm_parameter" "function_read_cloudfront_logs_arn" {
  name = "/meli/url-shortener/sam-api/lambda/read-cloudfront-logs/arn"
}

resource "aws_lambda_permission" "s3_invoke_read_cloudfront_logs" {
  action        = "lambda:InvokeFunction"
  function_name = data.aws_ssm_parameter.function_read_cloudfront_logs_arn.value
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_ssm_parameter.url_cloudfront_logs_bucket_name_arn.value
}

resource "aws_s3_bucket_notification" "url_cloudfront_logs_bucket_notification" {
  bucket = data.aws_ssm_parameter.url_cloudfront_logs_bucket_name.value

  lambda_function {
    lambda_function_arn = data.aws_ssm_parameter.function_read_cloudfront_logs_arn.value
    events              = ["s3:ObjectCreated:Put"]
  }

  depends_on = [
    aws_lambda_permission.s3_invoke_read_cloudfront_logs,
  ]
}
