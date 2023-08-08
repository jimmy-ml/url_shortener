import json
import os
import boto3

dynamo_resource = boto3.resource('dynamodb')
s3_client = boto3.client('s3')


def delete_short_url_dynamo(dynamo_table, key):
    table = dynamo_resource.Table(dynamo_table)
    table.update_item(
        Key={'url_key': key},
        AttributeUpdates={
        'is_active': {
                'Value': False,
                'Action': 'PUT'
            }
        }
    )


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
    object_key = record['s3']['object']['key']
    dynamo_table = os.environ["DYNAMO_TABLE"]

    # delete item in dynamo
    delete_short_url_dynamo(dynamo_table, object_key)
    return {
        "dynamo_table": dynamo_table,
        "url_key": object_key
    }
