locals {
  rds_admin_secret = {
    username = var.rds_config.master_username
    password = ephemeral.aws_secretsmanager_random_password.rds_admin_pwd.random_password
  }
  admin_pwd_version = 1

  rds_bedrock_secret = {
    username = "bedrock_user"
    password = ephemeral.aws_secretsmanager_random_password.rds_bedrock_pwd.random_password
  }
  bedrock_pwd_version = 1
}

# rds admin user
ephemeral "aws_secretsmanager_random_password" "rds_admin_pwd" {
  exclude_characters = "\"@/\\'`"
}

resource "aws_secretsmanager_secret" "rds_admin_secret" {
  name        = "${var.resource_name_prefix}-admin-secret"
  description = "Secret for admin credentials"
}

resource "aws_secretsmanager_secret_version" "rds_admin_secret_version" {
  secret_id                = aws_secretsmanager_secret.rds_admin_secret.id
  secret_string_wo         = jsonencode(local.rds_admin_secret)
  secret_string_wo_version = local.admin_pwd_version
}

# rds bedrock user
ephemeral "aws_secretsmanager_random_password" "rds_bedrock_pwd" {
  exclude_characters = "\"@/\\'`"
}

resource "aws_secretsmanager_secret" "rds_bedrock_secret" {
  name        = "${var.resource_name_prefix}-bedrock-secret"
  description = "Secret for bedrock credentials"
}

resource "aws_secretsmanager_secret_version" "rds_bedrock_secret_version" {
  secret_id                = aws_secretsmanager_secret.rds_bedrock_secret.id
  secret_string_wo         = jsonencode(local.rds_bedrock_secret)
  secret_string_wo_version = local.bedrock_pwd_version
}
