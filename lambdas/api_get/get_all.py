import json
import os
import boto3
from boto3.dynamodb.conditions import Key
from decimal import Decimal

def build_response(code, message):
    return {
        'statusCode': code,
        'headers': {
            'Content-Type': 'application/json',
        },
        'body': message
    }

def item_transform(item):
    return { attribute:(int(value) 
            if isinstance(value, Decimal) 
            else value)
            for attribute, value in item.items() }


def lambda_handler(event, context):
    """
    Principal Lambda Handler
    """
    # Log the received event
    print("Received event: " + json.dumps(event, indent=2))
    dynamo_table = 'meli-marketing-url-shortener-UrlShortenerTable-8HFRS6FOL2X5' # TODO
    global_index_name = 'target_url_index' # TODO

    dynamo_resouce = boto3.resource('dynamodb')
    table = dynamo_resouce.Table(dynamo_table)

    query_params = event['queryStringParameters']
    if query_params == None:
        response = table.scan()
    else:
        if 'target_url' in query_params:
            target_url = query_params['target_url']
            response = table.query(
                IndexName=global_index_name,
                KeyConditionExpression=Key('target_url').eq(target_url),
                FilterExpression=Key('is_active').eq(True)
            )

    response_body = [item_transform(dynamo_item)
                     for dynamo_item in response['Items']]

    return build_response(200, json.dumps(response_body))
