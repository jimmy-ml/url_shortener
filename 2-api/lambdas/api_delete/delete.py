import json
import os
import boto3
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


def delete_object_s3(s3_bucket, s3_key):
    try:
        response = s3_client.delete_object(
            Bucket=s3_bucket,
            Key=s3_key,
        )
        response_body = {
            "url_key": s3_key
        }
        print(f"DELETE object in S3 {s3_bucket}", response_body)
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
    bucket_name = os.environ["BUCKET_NAME"]
    path_parameters = event.get('pathParameters')
    url_key = path_parameters['url_key']

    # delete object in bucket
    return delete_object_s3(bucket_name, url_key)
