locals {
  bucket_permissions_list = flatten(
    [for bucket in data.aws_s3_bucket.kb_bucket_data_source : [bucket.arn, "${bucket.arn}/*"]]
  )
}

resource "aws_iam_role" "bedrock_kb_role" {
  name = "${var.resource_name_prefix}-bedrock-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-bedrock-role"
  })
}

resource "aws_iam_policy" "bedrock_kb_policy" {
  name        = "${var.resource_name_prefix}-bedrock-kb-policy"
  description = "Policy per Bedrock"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds:DescribeDBClusters",
          "rds-data:ExecuteStatement",
          "rds-data:BatchExecuteStatement"
        ],
        Effect   = "Allow",
        Resource = aws_rds_cluster.aurora_serverless.arn
      },
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Effect   = "Allow",
        Resource = aws_secretsmanager_secret.rds_bedrock_secret.arn
      },
      {
        Action = [
          "bedrock:InvokeModel"
        ],
        Effect   = "Allow",
        Resource = data.aws_bedrock_foundation_model.embedding.model_arn
      },
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ],
        Effect   = "Allow",
        Resource = local.bucket_permissions_list
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "bedrock_policy_attachment" {
  role       = aws_iam_role.bedrock_kb_role.name
  policy_arn = aws_iam_policy.bedrock_kb_policy.arn
}
