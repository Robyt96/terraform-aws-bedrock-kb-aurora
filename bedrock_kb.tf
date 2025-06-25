resource "aws_bedrockagent_knowledge_base" "kb" {
  for_each = toset(var.kb_config)
  name     = each.value.kb_name
  role_arn = aws_iam_role.bedrock_kb_role.arn
  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = data.aws_bedrock_foundation_model.embedding.model_arn
      embedding_model_configuration {
        bedrock_embedding_model_configuration {
          dimensions = var.embedding_config.dimensions
        }
      }
    }
    type = "VECTOR"
  }

  storage_configuration {
    type = "RDS"
    rds_configuration {
      credentials_secret_arn = aws_secretsmanager_secret.bedrock_user.arn
      database_name          = each.value.kb_name
      table_name             = "bedrock_integration.bedrock_kb"
      resource_arn           = aws_rds_cluster.aurora_serverless.arn
      field_mapping {
        metadata_field    = "metadata"
        primary_key_field = "id"
        text_field        = "chunks"
        vector_field      = "embedding"
      }
    }

  }

  depends_on = [
    aws_rds_cluster.aurora_serverless,
    aws_rds_cluster_instance.aurora_instance,
    null_resource.execute_sql_commands
  ]
}

resource "aws_bedrockagent_data_source" "kb_data_source" {
  for_each             = toset(var.kb_config)
  knowledge_base_id    = aws_bedrockagent_knowledge_base.kb[each.value].id // to check
  name                 = "${each.value.kb_name}-data-source"
  data_deletion_policy = "RETAIN"

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn         = data.aws_s3_bucket.kb_bucket_data_source[each.value].arn // to check
      inclusion_prefixes = each.value.source_bucket_prefixes                        // to check
    }
  }

  depends_on = [
    aws_bedrockagent_knowledge_base.kb
  ]
}
