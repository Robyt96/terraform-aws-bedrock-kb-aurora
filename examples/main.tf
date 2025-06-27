module "kb" {
  source = "../terraform-aws-bedrock-kb-aurora"

  aws_region = "eu-central-1"
  kb_config = [{
    kb_name                = "kb_name_1"
    source_bucket_name     = "bedrock-knowledge-base-12345"
    source_bucket_prefixes = ["prefix_1"]
    },
    {
      kb_name                = "kb_name_2"
      source_bucket_name     = "bedrock-knowledge-base-12345"
      source_bucket_prefixes = ["prefix_2", "prefix_3"]
  }]

  rds_config = {
    vpc_id     = "vpc-ids123"
    subnet_ids = ["subnet-1234aa567", "subnet-1234aa987"]
  }

  resource_name_prefix = "resource-prfix-kb"

  tags = {
    "project" : "kb-tag"
  }
}

provider "aws" {
  region = "eu-central-1"
}

terraform {
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}