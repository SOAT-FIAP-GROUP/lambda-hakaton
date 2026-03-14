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


# Deployment & stage
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeploy = sha1(join("", [
      aws_api_gateway_rest_api.api.id
    ]))
  }
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
  request_parameters = {
    "method.request.path.proxy"           = true
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



