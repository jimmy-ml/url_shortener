import json
import os
import boto3

dynamo_resource = boto3.resource('dynamodb')
s3_client = boto3.client('s3')


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

    # params
    record = event.get("Records")[0]
    bucket_name = record['s3']['bucket']['name']
    object_key = record['s3']['object']['key']
    dynamo_table = os.environ["DYNAMO_TABLE"]

    # get WebsiteRedirectLocation metadata from bucket object
    target_url = get_target_url(bucket_name, object_key)

    # put item to dynamo
    put_short_url_dynamo(dynamo_table, object_key, target_url)
    return {
        "dynamo_table": dynamo_table,
        "target_url": target_url,
        "url_key": object_key
    }
