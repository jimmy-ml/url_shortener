import json
import os
import boto3
import gzip
import io
from decimal import Decimal
from collections import Counter

dynamo_resource = boto3.resource('dynamodb')
s3_client = boto3.client('s3')

def get_log_file(bucket_name, object_key):
    return s3_client.get_object(
        Bucket=bucket_name,
        Key=object_key,
    )['Body'].read()

def update_clicks_short_url_dynamo(table, key, count):
    table.update_item(
        Key={'url_key': key},
        UpdateExpression='SET #clicks = #clicks + :n',
        ExpressionAttributeNames={'#clicks': 'clicks'},
        ExpressionAttributeValues={':n': Decimal(count)}
    )

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
    table = dynamo_resource.Table(dynamo_table)

    # read gz file from S3
    gz_file = get_log_file(bucket_name, object_key)
    with gzip.GzipFile(fileobj=io.BytesIO(gz_file), mode='rb') as gzip_file:
        raw_file = gzip_file.read()
    raw_file = raw_file.decode('utf-8')

    # read every line and get short_key invocations
    file_lines = raw_file.strip().split('\n')[2:]

    logs_clicks_invocations = []
    for line in file_lines:
        columns = line.split('\t')
        if columns[5] == 'GET' and columns[8] == '301' and '/url' not in columns[7]:
            logs_clicks_invocations.append(columns[7].replace('/', ''))

    # update dynamo items with clicks count
    short_key_count = Counter(logs_clicks_invocations)

    for short_key, count in short_key_count.items():
        update_clicks_short_url_dynamo(table, short_key, count)

    return short_key_count
