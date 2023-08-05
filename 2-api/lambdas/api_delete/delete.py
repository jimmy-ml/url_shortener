import json
import os
import boto3

s3_client = boto3.client('s3')

def build_response(code, message):
    return {
        'statusCode': code,
        'headers': {
            'Content-Type': 'application/json',
        },
        'body': message
    }

def delete_object_s3(s3_bucket, s3_key):
    s3_client.delete_object(
        Bucket=s3_bucket,
        Key=s3_key,
    )

def lambda_handler(event, context):
    """
    Principal Lambda Handler
    """
    # Log the received event
    print("Received event: " + json.dumps(event, indent=2))

    # params
    bucket_name = os.environ["BUCKET_NAME"]
    path_parameters = event.get('pathParameters')
    url_key = path_parameters['url_key']

    # delete object in bucket
    delete_object_s3(bucket_name, url_key)

    response_body = {
        "url_key": url_key
    }
    return build_response(200, json.dumps(response_body))
