import json
import os
import boto3
import secrets

s3_client = boto3.client('s3')

def build_response(code, message):
    return {
        'statusCode': code,
        'headers': {
            'Content-Type': 'application/json',
        },
        'body': message
    }

def put_url_key_s3(s3_bucket, s3_key, target_url):
    s3_client.put_object(
        Bucket=s3_bucket,
        Key=s3_key,
        WebsiteRedirectLocation=target_url
    )

def lambda_handler(event, context):
    """
    Principal Lambda Handler
    """
    # Log the received event
    print("Received event: " + json.dumps(event, indent=2))

    # params
    body = event.get("body")
    try:
        body = json.loads(body)
    except Exception:
        print("Se usa body original")
    bucket_name = os.environ["BUCKET_NAME"]

    # random string that’ll be part of the shortened URL
    chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    key = "".join(secrets.choice(chars) for _ in range(6))

    # put object in bucket
    put_url_key_s3(bucket_name, key, body["target_url"])

    response_body = {
        "target_url": body["target_url"],
        "url_key": key
    }
    return build_response(200, json.dumps(response_body))
