data "aws_bedrock_foundation_model" "embedding" {
  model_id = var.embedding_config.model_id
}

data "aws_s3_bucket" "kb_bucket_data_source" {
  for_each = local.kb_map
  bucket   = each.value.source_bucket_name
}
