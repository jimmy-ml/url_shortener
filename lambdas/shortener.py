import secrets
import json
import os
import boto3

def build_response(code, message):
    return {
        'statusCode': code,
        'headers': {
            'Content-Type': 'application/json',
        },
        'body': message
    }

def lambda_handler(event, context):
    """
    Principal Lambda Handler
    """
    # Log the received event
    # print("Received event: " + json.dumps(event, indent=2))
    dynamo_table = os.environ['DYNAMO_TABLE']
    print(dynamo_table)

    body = event.get("body")
    try:
        body = json.loads(body)
    except Exception:
        print("Se usa body original")

    chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    key = "".join(secrets.choice(chars) for _ in range(6)) # random string that’ll be part of the shortened URL
    response_body = {
        "target_url": body["target_url"],
        "url_key": key,
        "clicks": 0,
        "is_active": True
    }
    print(response_body)

    dynamo_client = boto3.resource('dynamodb')
    table = dynamo_client.Table(dynamo_table)
    response = table.put_item(Item=response_body)
    print(response)

    return build_response(200, json.dumps(response_body))

# target_url = 
# is_active = Boolean, default=True
# clicks = Integer, default=0

# /{url_key} >>>>>>> forward_to_target_url()
