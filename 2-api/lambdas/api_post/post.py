import json
import os
import boto3
import secrets
from botocore.exceptions import ClientError

s3_client = boto3.client('s3')

def build_response(code, message):
    return {
        'statusCode': code,
        'headers': {
            'Content-Type': 'application/json',
        },
        'body': json.dumps(message)
    }


def boto_error(exception):
    print('Error:', exception.response)
    body = {
        'code': exception.response['Error']['Code'],
        'message': exception.response['Error']['Message'],
    }

    return build_response(
        int(exception.response['ResponseMetadata']['HTTPStatusCode']), body
    )


def put_url_key_s3(s3_bucket, s3_key, target_url):
    try:
        response = s3_client.put_object(
            Bucket=s3_bucket,
            Key=s3_key,
            WebsiteRedirectLocation=target_url
        )
        response_body = {
            "target_url": target_url,
            "url_key": s3_key
        }
        print(f"PUT object in S3 {s3_bucket}", response_body)
        return build_response(
            response['ResponseMetadata']['HTTPStatusCode'], response_body
        )
    except ClientError as e:
        return boto_error(e)


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
    return put_url_key_s3(bucket_name, key, body["target_url"])
