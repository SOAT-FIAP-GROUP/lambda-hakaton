# REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.project_name}-api"
  description = "API Gateway for signup/signin/get-user with Cognito authorizer"
}

# root resource id
data "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  path        = "/"
}

# Create /signup resource
resource "aws_api_gateway_resource" "signup" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "signup"
}

# Create /signin resource
resource "aws_api_gateway_resource" "signin" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "signin"
}

# Create /me resource
resource "aws_api_gateway_resource" "me" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "me"
}

# Cognito Authorizer
resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name                             = "${var.project_name}-cognito-auth"
  rest_api_id                      = aws_api_gateway_rest_api.api.id
  type                             = "COGNITO_USER_POOLS"
  provider_arns                    = [aws_cognito_user_pool.user_pool.arn]
  identity_source                  = "method.request.header.Authorization"
  authorizer_result_ttl_in_seconds = 300
}

# Methods and integrations

# POST /signup -> signup lambda
resource "aws_api_gateway_method" "signup_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.signup.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "signup_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.signup.id
  http_method = aws_api_gateway_method.signup_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.signup.invoke_arn
}

# POST /signin -> signin lambda
resource "aws_api_gateway_method" "signin_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.signin.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "signin_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.signin.id
  http_method = aws_api_gateway_method.signin_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.signin.invoke_arn
}

# GET /me -> protected, cognito authorizer
resource "aws_api_gateway_method" "me_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.me.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  request_parameters = {
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "me_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.me.id
  http_method = aws_api_gateway_method.me_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_user.invoke_arn
}

# Deployment & stage
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeploy = sha1(join("", [
      aws_lambda_function.signup.source_code_hash,
      aws_lambda_function.signin.source_code_hash,
      aws_lambda_function.get_user.source_code_hash,
      aws_api_gateway_rest_api.api.id
    ]))
  }

  depends_on = [
    aws_api_gateway_integration.signup_integration,
    aws_api_gateway_integration.signin_integration,
    aws_api_gateway_integration.me_integration
  ]
}

resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  stage_name    = "prod"

  depends_on = [
    aws_api_gateway_deployment.deployment
  ]
  lifecycle {
    # Isso garante que mudanças no deployment não tentem recriar o stage
    ignore_changes = [deployment_id]
  }
}

# Give API Gateway permission to invoke the Lambdas
resource "aws_lambda_permission" "allow_apigw_signup" {
  statement_id  = "AllowAPIGatewayInvokeSignup"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.signup.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/signup"
}

resource "aws_lambda_permission" "allow_apigw_signin" {
  statement_id  = "AllowAPIGatewayInvokeSignin"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.signin.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/signin"
}

resource "aws_lambda_permission" "allow_apigw_getuser" {
  statement_id  = "AllowAPIGatewayInvokeGetUser"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/me"
}

# ========================================================================
#                        INCLUI OS PATHS DA APLICAÇÃO
# ========================================================================

resource "aws_api_gateway_resource" "services" {
  for_each = var.services
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "${each.key}"
}

resource "aws_api_gateway_resource" "proxy" {
  for_each = var.services
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.services[each.key].id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_any" {
  for_each = var.services
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.proxy[each.key].id
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  request_parameters = {
    "method.request.path.proxy"           = true
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "proxy_integration" {
  for_each = var.services
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.proxy[each.key].id
  http_method             = aws_api_gateway_method.proxy_any[each.key].http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${each.value}:8080/{proxy}"
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}



