locals {
  cluster_name     = "${var.resource_name_prefix}-vector-store"
  db_instance_name = "${local.cluster_name}-instance"
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "${var.resource_name_prefix}-subnet-group"
  subnet_ids = var.rds_config.subnet_ids
}

resource "aws_rds_cluster" "aurora_serverless" {
  cluster_identifier         = local.cluster_name
  engine                     = "aurora-postgresql"
  engine_version             = "16.4"
  engine_mode                = "provisioned"
  master_username            = var.rds_config.master_username
  master_password_wo         = local.rds_secret["password"]
  master_password_wo_version = local.admin_pwd_version
  database_name              = "default_db"
  db_subnet_group_name       = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids     = [aws_security_group.aurora_sg.id]
  skip_final_snapshot        = true
  enable_http_endpoint       = true

  serverlessv2_scaling_configuration {
    max_capacity             = var.rds_config.max_capacity
    min_capacity             = var.rds_config.min_capacity
    seconds_until_auto_pause = var.rds_config.seconds_until_auto_pause
  }

  tags = merge(var.tags, {
    Name = local.cluster_name
  })
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  cluster_identifier  = aws_rds_cluster.aurora_serverless.id
  identifier          = local.db_instance_name
  instance_class      = "db.serverless"
  engine              = aws_rds_cluster.aurora_serverless.engine
  engine_version      = aws_rds_cluster.aurora_serverless.engine_version
  publicly_accessible = false

  tags = merge(var.tags, {
    Name = local.db_instance_name
  })
}

resource "null_resource" "execute_sql_commands" {
  for_each = toset(var.kb_config)
  triggers = {
    cluster_arn = aws_rds_cluster.aurora_serverless.arn
  }

  depends_on = [
    aws_rds_cluster.aurora_serverless,
    aws_rds_cluster_instance.aurora_instance
  ]

  provisioner "local-exec" {
    command = <<EOT
      aws rds-data execute-statement \
          --resource-arn ${aws_rds_cluster.aurora_serverless.arn} \
          --secret-arn ${aws_secretsmanager_secret.rds_admin_secret.arn} \
          --database ${aws_rds_cluster.aurora_serverless.database_name} \
          --region ${var.aws_region} \
          --sql "CREATE DATABASE ${each.value.kb_name};"

      aws rds-data execute-statement \
        --resource-arn ${aws_rds_cluster.aurora_serverless.arn} \
        --secret-arn ${aws_secretsmanager_secret.rds_admin_secret.arn} \
        --database ${each.value.kb_name} \
        --region ${var.aws_region} \
        --sql "CREATE EXTENSION IF NOT EXISTS vector;"

      aws rds-data execute-statement \
        --resource-arn ${aws_rds_cluster.aurora_serverless.arn} \
        --secret-arn ${aws_secretsmanager_secret.rds_admin_secret.arn} \
        --database ${each.value.kb_name} \
        --region ${var.aws_region} \
        --sql "SELECT extversion FROM pg_extension WHERE extname='vector';"

      aws rds-data execute-statement \
        --resource-arn ${aws_rds_cluster.aurora_serverless.arn} \
        --secret-arn ${aws_secretsmanager_secret.rds_admin_secret.arn} \
        --database ${each.value.kb_name} \
        --region ${var.aws_region} \
        --sql "CREATE SCHEMA bedrock_integration;"

      aws rds-data execute-statement \
        --resource-arn ${aws_rds_cluster.aurora_serverless.arn} \
        --secret-arn ${aws_secretsmanager_secret.rds_admin_secret.arn} \
        --database ${each.value.kb_name} \
        --region ${var.aws_region} \
        --sql "CREATE ROLE bedrock_user WITH PASSWORD 'password' LOGIN;"

      aws rds-data execute-statement \
        --resource-arn ${aws_rds_cluster.aurora_serverless.arn} \
        --secret-arn ${aws_secretsmanager_secret.rds_admin_secret.arn} \
        --database ${each.value.kb_name} \
        --region ${var.aws_region} \
        --sql "GRANT ALL ON SCHEMA bedrock_integration TO bedrock_user;"

      aws rds-data execute-statement \
        --resource-arn ${aws_rds_cluster.aurora_serverless.arn} \
        --secret-arn ${aws_secretsmanager_secret.rds_admin_secret.arn} \
        --database ${each.value.kb_name} \
        --region ${var.aws_region} \
        --sql "CREATE TABLE bedrock_integration.bedrock_kb (id uuid PRIMARY KEY, embedding vector(1024), chunks text, metadata jsonb);"

      aws rds-data execute-statement \
        --resource-arn ${aws_rds_cluster.aurora_serverless.arn} \
        --secret-arn ${aws_secretsmanager_secret.rds_admin_secret.arn} \
        --database ${each.value.kb_name} \
        --region ${var.aws_region} \
        --sql "CREATE INDEX ON bedrock_integration.bedrock_kb USING hnsw (embedding vector_cosine_ops);"

      aws rds-data execute-statement \
        --resource-arn ${aws_rds_cluster.aurora_serverless.arn} \
        --secret-arn ${aws_secretsmanager_secret.rds_admin_secret.arn} \
        --database ${each.value.kb_name} \
        --region ${var.aws_region} \
        --sql "CREATE INDEX ON bedrock_integration.bedrock_kb USING hnsw (embedding vector_cosine_ops) WITH (ef_construction=256);"

      aws rds-data execute-statement \
        --resource-arn ${aws_rds_cluster.aurora_serverless.arn} \
        --secret-arn ${aws_secretsmanager_secret.rds_admin_secret.arn} \
        --database ${each.value.kb_name} \
        --region ${var.aws_region} \
        --sql "CREATE INDEX ON bedrock_integration.bedrock_kb USING gin (to_tsvector('simple', chunks));"

      aws rds-data execute-statement \
        --resource-arn ${aws_rds_cluster.aurora_serverless.arn} \
        --secret-arn ${aws_secretsmanager_secret.rds_admin_secret.arn} \
        --database ${each.value.kb_name} \
        --region ${var.aws_region} \
        --sql "ALTER DATABASE postgres SET search_path TO bedrock_integration, public;"

      aws rds-data execute-statement \
        --resource-arn ${aws_rds_cluster.aurora_serverless.arn} \
        --secret-arn ${aws_secretsmanager_secret.rds_admin_secret.arn} \
        --database ${each.value.kb_name} \
        --region ${var.aws_region} \
        --sql "GRANT ALL PRIVILEGES ON TABLE bedrock_integration.bedrock_kb TO bedrock_user;"
    EOT
  }
}
