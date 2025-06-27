# AWS Bedrock Knowledge Bases with Aurora Serverless module

Terraform module, which creates one or more Bedrock Knowledge Bases with S3 Bucket as data source and RDS Aurora Serverless as Vector Store. With default RDS configuration values, the Aurora cluster scales down to 0 ACU (minimum capacity) after 15 minutes without connections to the DB. This is useful to development enviroments where you want to test Bedrock Knowledge Bases with minimum spending.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_bedrockagent_data_source.kb_data_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_data_source) | resource |
| [aws_bedrockagent_knowledge_base.kb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_knowledge_base) | resource |
| [aws_db_subnet_group.aurora_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_iam_policy.bedrock_kb_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.bedrock_kb_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.bedrock_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_rds_cluster.aurora_serverless](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster_instance.aurora_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_secretsmanager_secret.rds_admin_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.rds_bedrock_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.rds_admin_secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.rds_bedrock_secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [null_resource.execute_sql_commands](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_bedrock_foundation_model.embedding](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/bedrock_foundation_model) | data source |
| [aws_s3_bucket.kb_bucket_data_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_embedding_config"></a> [embedding\_config](#input\_embedding\_config) | Configuration of the embedding foundation model to use | <pre>object({<br>    model_id   = string<br>    dimensions = number<br>  })</pre> | <pre>{<br>  "dimensions": 1024,<br>  "model_id": "amazon.titan-embed-text-v2:0"<br>}</pre> | no |
| <a name="input_kb_config"></a> [kb\_config](#input\_kb\_config) | List of objects representing a Bedrock Knowledge Base configuration | <pre>list(object({<br>    kb_name                = string<br>    source_bucket_name     = string<br>    source_bucket_prefixes = optional(list(string))<br>  }))</pre> | n/a | yes |
| <a name="input_rds_config"></a> [rds\_config](#input\_rds\_config) | Configuration of RDS Aurora Serverless for Vector Store | <pre>object({<br>    vpc_id                   = string<br>    subnet_ids               = list(string)<br>    master_username          = optional(string, "db_user")<br>    max_capacity             = optional(number, 1.0)<br>    min_capacity             = optional(number, 0.0)<br>    seconds_until_auto_pause = optional(number, 900)<br>  })</pre> | n/a | yes |
| <a name="input_resource_name_prefix"></a> [resource\_name\_prefix](#input\_resource\_name\_prefix) | Name prefix of created resources | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to AWS resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_knownledge_base_ids"></a> [knownledge\_base\_ids](#output\_knownledge\_base\_ids) | n/a |
<!-- END_TF_DOCS -->