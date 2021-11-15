import json
import boto3
import codecs
import csv

s3_client = boto3.client('s3')
dynamodb_client = boto3.resource('dynamodb')

def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    file_name = event['Records'][0]['s3']['object']['key']
    print('{}-{}'.format(bucket, file_name))
    file = s3_client.get_object(Bucket = bucket, Key=file_name)
    
    for record in csv.DictReader(codecs.getreader("utf-8")(file['Body'])):
        player_tbl = dynamodb_client.Table('players')
        print(record)
        player_tbl.put_item(Item=record)
    
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }