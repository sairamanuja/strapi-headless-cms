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

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.project_name}/db-password"
  description             = "PostgreSQL database password for RDS"
  recovery_window_in_days = 7

  tags = {
    Name        = "${var.project_name}-db-password"
    Environment = var.environment
    Purpose     = "RDS database authentication"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

resource "aws_secretsmanager_secret" "admin_jwt_secret" {
  name                    = "${var.project_name}/admin-jwt-secret"
  description             = "Strapi admin panel JWT secret"
  recovery_window_in_days = 7

  tags = {
    Name        = "${var.project_name}-admin-jwt-secret"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "admin_jwt_secret" {
  secret_id     = aws_secretsmanager_secret.admin_jwt_secret.id
  secret_string = base64encode(random_password.admin_jwt_secret.result)
}

resource "aws_secretsmanager_secret" "api_token_salt" {
  name                    = "${var.project_name}/api-token-salt"
  description             = "Salt for Strapi API token generation"
  recovery_window_in_days = 7

  tags = {
    Name        = "${var.project_name}-api-token-salt"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "api_token_salt" {
  secret_id     = aws_secretsmanager_secret.api_token_salt.id
  secret_string = base64encode(random_password.api_token_salt.result)
}

resource "aws_secretsmanager_secret" "app_keys" {
  name                    = "${var.project_name}/app-keys"
  description             = "Strapi application keys (4 keys combined)"
  recovery_window_in_days = 7

  tags = {
    Name        = "${var.project_name}-app-keys"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "app_keys" {
  secret_id     = aws_secretsmanager_secret.app_keys.id
  secret_string = join(",", [for p in random_password.app_keys : base64encode(p.result)])
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name                    = "${var.project_name}/jwt-secret"
  description             = "Strapi JWT secret for user authentication"
  recovery_window_in_days = 7

  tags = {
    Name        = "${var.project_name}-jwt-secret"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id     = aws_secretsmanager_secret.jwt_secret.id
  secret_string = base64encode(random_password.jwt_secret.result)
}

resource "aws_secretsmanager_secret" "transfer_token_salt" {
  name                    = "${var.project_name}/transfer-token-salt"
  description             = "Salt for Strapi transfer token generation"
  recovery_window_in_days = 7

  tags = {
    Name        = "${var.project_name}-transfer-token-salt"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "transfer_token_salt" {
  secret_id     = aws_secretsmanager_secret.transfer_token_salt.id
  secret_string = base64encode(random_password.transfer_token_salt.result)
}

resource "aws_secretsmanager_secret" "encryption_key" {
  name                    = "${var.project_name}/encryption-key"
  description             = "Strapi encryption key for sensitive data"
  recovery_window_in_days = 7

  tags = {
    Name        = "${var.project_name}-encryption-key"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "encryption_key" {
  secret_id     = aws_secretsmanager_secret.encryption_key.id
  secret_string = base64encode(random_password.encryption_key.result)
}
