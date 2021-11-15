provider "aws" {
  region = "us-west-2"
}


data "aws_caller_identity" "caller" {}
data "aws_availability_zones" "zones" {}


# Setup basic vpc
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.zones.names, 0, 2)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# create a role for lambda function
resource "aws_iam_role" "lambda" {
    name = "HSRoleLambda"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
            }
        ]
    })

    tags = {
        Name = "HSRoleLambda"
    }
}


resource "aws_iam_role_policy_attachment" "read_cloudwatch" {
    role = aws_iam_role.lambda.name
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "read_s3" {
    role = aws_iam_role.lambda.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "read_dynamodb" {
    role = aws_iam_role.lambda.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}


resource "aws_s3_bucket" "data" {
    bucket = "data-${data.aws_caller_identity.caller.account_id}"

    tags = {
        Name = "data-${data.aws_caller_identity.caller.account_id}"
    }
}

resource "aws_dynamodb_table" "player" {
    name = "players"
    hash_key = "id"
    range_key = "age"

    read_capacity = 20
    write_capacity = 20

    attribute {
      name = "id"
      type = "S"
    }

    attribute {
      name = "name"
      type = "S"
    }

    attribute {
      name = "age"
      type = "S"
    }

    ttl {
        attribute_name = "ttl"
        enabled = true
    }

    local_secondary_index {
      name = "nameIdx"
      range_key = "name"
      projection_type = "INCLUDE"
      non_key_attributes = [ "experienced" ]
    }
}
