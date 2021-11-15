# Activities 

## 1. Setup Network
#### VPC and Subnets
Create simple VPC `my-vpc` with two subnets

#### S3 Bucket
Create s3 bucket `data-<accountid>` for recieving the data

#### DyanmoDB Table
Create a dynamodb table `players` to store the data

#### Lambda IAM role
Create an IAM role `HSRoleLambda` which can 
- read s3 bucket
- read/write CloudWatch event
- write into dynamodb

#### Define your labda
- Create Lambda function
    - Set Role to `HSRoleLambda`
- Add code and deploy
- Configure trigger of S3 type on `ObjectCreated` and apply

## 2. Test 
Copy data file into s3 bucket
```bash
aws s3 cp data/part.csv s3://data-<accountid>/part-1.csv
```
This should trigger the labda and then labda should insert the data into dynamodb table.

Chec the logs in cloudwatch for details.