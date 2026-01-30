# Signup Lambda
resource "aws_lambda_function" "signup" {
  filename         = var.lambda_signup_zip
  function_name    = "${var.project_name}-signup"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256(var.lambda_signup_zip)
  timeout          = 10

  environment {
    variables = {
      USER_POOL_ID     = aws_cognito_user_pool.user_pool.id
      USER_POOL_CLIENT = aws_cognito_user_pool_client.user_pool_client.id
    }
  }
}

# Signin Lambda
resource "aws_lambda_function" "signin" {
  filename         = var.lambda_signin_zip
  function_name    = "${var.project_name}-signin"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256(var.lambda_signin_zip)
  timeout          = 10

  environment {
    variables = {
      USER_POOL_ID     = aws_cognito_user_pool.user_pool.id
      USER_POOL_CLIENT = aws_cognito_user_pool_client.user_pool_client.id
    }
  }
}

resource "aws_lambda_function" "get_user" {
  filename         = var.lambda_getuser_zip
  function_name    = "${var.project_name}-get-user"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256(var.lambda_getuser_zip)
  timeout          = 10

  depends_on = [
    aws_cognito_user_pool.user_pool
  ]
}
