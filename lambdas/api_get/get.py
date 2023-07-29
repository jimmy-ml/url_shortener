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
    # print("Received event: " + json.dumps(event, indent=2))
    dynamo_table = 'meli-marketing-url-shortener-UrlShortenerTable-8HFRS6FOL2X5' # TODO

    path_parameters = event.get('pathParameters')
    url_key = path_parameters['url_key']
    print(url_key)

    dynamo_resouce = boto3.resource('dynamodb')
    table = dynamo_resouce.Table(dynamo_table)

    response = table.query(
        KeyConditionExpression=Key('url_key').eq(url_key),
        FilterExpression=Key('is_active').eq(True)
    )
    dynamo_item = item_transform(response['Items'][0])

    return build_response(200, json.dumps(dynamo_item))
