resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.project_name}-user-pool"

  # Identity will be the username (required)
  # Custom attributes cannot be required; mark them optional
  schema {
    name                = "cpf"
    attribute_data_type = "String"
    required            = false # change to false
    mutable             = false
    string_attribute_constraints {
      min_length = 11
      max_length = 11
    }
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    required            = false # optional
    mutable             = true
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = false
    mutable             = true
  }

  schema {
    name                = "cellphone"
    attribute_data_type = "String"
    required            = false
    mutable             = true
  }

  password_policy {
    minimum_length    = 6
    require_lowercase = false
    require_uppercase = false
    require_numbers   = false
    require_symbols   = false
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  lifecycle {
    ignore_changes = [schema]
  }

  # Remove username_attributes / alias_attributes
  tags = {
    Project = var.project_name
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "${var.project_name}-client"
  user_pool_id = aws_cognito_user_pool.user_pool.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]

  generate_secret               = false
  prevent_user_existence_errors = "ENABLED"

  allowed_oauth_flows_user_pool_client = false
  supported_identity_providers         = ["COGNITO"]
}

# Optional: hosted UI domain (useful if you want the Cognito Hosted UI)
resource "aws_cognito_user_pool_domain" "domain" {
  count        = var.enable_user_pool_domain ? 1 : 0
  domain       = var.user_pool_domain_prefix
  user_pool_id = aws_cognito_user_pool.user_pool.id
}
