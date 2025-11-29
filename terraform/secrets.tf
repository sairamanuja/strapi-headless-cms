# =============================================================================
# Generate Random Secrets
# =============================================================================

resource "random_password" "admin_jwt_secret" {
  length  = 32
  special = false
}

resource "random_password" "api_token_salt" {
  length  = 32
  special = false
}

resource "random_password" "app_keys" {
  count   = 4
  length  = 24
  special = false
}

resource "random_password" "jwt_secret" {
  length  = 32
  special = false
}

resource "random_password" "transfer_token_salt" {
  length  = 32
  special = false
}

resource "random_password" "encryption_key" {
  length  = 32
  special = false
}

# =============================================================================
# Secrets Manager - Strapi Secrets
# =============================================================================

resource "aws_secretsmanager_secret" "strapi" {
  name                    = "${var.project_name}/secrets"
  description             = "Strapi application secrets"
  recovery_window_in_days = 7

  tags = {
    Name = "${var.project_name}-secrets"
  }
}

resource "aws_secretsmanager_secret_version" "strapi" {
  secret_id = aws_secretsmanager_secret.strapi.id

  secret_string = jsonencode({
    DATABASE_PASSWORD    = random_password.db_password.result
    ADMIN_JWT_SECRET     = base64encode(random_password.admin_jwt_secret.result)
    API_TOKEN_SALT       = base64encode(random_password.api_token_salt.result)
    APP_KEYS             = join(",", [for p in random_password.app_keys : base64encode(p.result)])
    JWT_SECRET           = base64encode(random_password.jwt_secret.result)
    TRANSFER_TOKEN_SALT  = base64encode(random_password.transfer_token_salt.result)
    ENCRYPTION_KEY       = base64encode(random_password.encryption_key.result)
  })
}

# =============================================================================
# Individual Secrets for ECS (easier to reference)
# =============================================================================

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.project_name}/db-password"
  description             = "Database password"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

resource "aws_secretsmanager_secret" "admin_jwt_secret" {
  name                    = "${var.project_name}/admin-jwt-secret"
  description             = "Admin JWT Secret"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "admin_jwt_secret" {
  secret_id     = aws_secretsmanager_secret.admin_jwt_secret.id
  secret_string = base64encode(random_password.admin_jwt_secret.result)
}

resource "aws_secretsmanager_secret" "api_token_salt" {
  name                    = "${var.project_name}/api-token-salt"
  description             = "API Token Salt"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "api_token_salt" {
  secret_id     = aws_secretsmanager_secret.api_token_salt.id
  secret_string = base64encode(random_password.api_token_salt.result)
}

resource "aws_secretsmanager_secret" "app_keys" {
  name                    = "${var.project_name}/app-keys"
  description             = "App Keys"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "app_keys" {
  secret_id     = aws_secretsmanager_secret.app_keys.id
  secret_string = join(",", [for p in random_password.app_keys : base64encode(p.result)])
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name                    = "${var.project_name}/jwt-secret"
  description             = "JWT Secret"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id     = aws_secretsmanager_secret.jwt_secret.id
  secret_string = base64encode(random_password.jwt_secret.result)
}

resource "aws_secretsmanager_secret" "transfer_token_salt" {
  name                    = "${var.project_name}/transfer-token-salt"
  description             = "Transfer Token Salt"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "transfer_token_salt" {
  secret_id     = aws_secretsmanager_secret.transfer_token_salt.id
  secret_string = base64encode(random_password.transfer_token_salt.result)
}

resource "aws_secretsmanager_secret" "encryption_key" {
  name                    = "${var.project_name}/encryption-key"
  description             = "Encryption Key"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "encryption_key" {
  secret_id     = aws_secretsmanager_secret.encryption_key.id
  secret_string = base64encode(random_password.encryption_key.result)
}
