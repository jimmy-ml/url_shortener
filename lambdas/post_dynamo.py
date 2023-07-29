import json
import boto3
import secrets

dynamo_resource = boto3.resource('dynamodb')
s3_client = boto3.client('s3')

def build_response(code, message):
    return {
        'statusCode': code,
        'headers': {
            'Content-Type': 'application/json',
        },
        'body': message
    }

def put_short_url_dynamo(dynamo_table, key, target_url):
    table = dynamo_resource.Table(dynamo_table)
    item = {
        "target_url": target_url,
        "url_key": key,
        "clicks": 0,
        "is_active": True
    }
    table.put_item(Item=item)

def get_target_url(bucket_name, object_key):
    return s3_client.get_object(
        Bucket=bucket_name,
        Key=object_key,
    )['WebsiteRedirectLocation']

def lambda_handler(event, context):
    """
    Principal Lambda Handler
    """
    # Log the received event
    print("Received event: " + json.dumps(event, indent=2))

    record = event.get("Records")[0]

    bucket_name = record['s3']['bucket']['name']
    object_key = record['s3']['object']['key']
    dynamo_table = 'meli-marketing-url-shortener-UrlShortenerTable-8HFRS6FOL2X5' # TODO

    target_url = get_target_url(bucket_name, object_key)
    print(target_url)

    put_short_url_dynamo(dynamo_table, object_key, target_url)
    response_body = {
        "target_url": target_url,
        "url_key": object_key
    }

    return build_response(200, json.dumps(response_body))
