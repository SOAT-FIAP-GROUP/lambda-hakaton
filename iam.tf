# IAM role for Lambda functions
resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-lambda-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_cognito_policy" {
  name = "${var.project_name}-lambda-cognito-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:AdminCreateUser",
          "cognito-idp:AdminGetUser",
          "cognito-idp:AdminInitiateAuth",
          "cognito-idp:AdminSetUserPassword",
          "cognito-idp:AdminConfirmSignUp",
          "cognito-idp:AdminUpdateUserAttributes",
          "cognito-idp:AdminRespondToAuthChallenge",
          "cognito-idp:SignUp",
          "cognito-idp:InitiateAuth",
          "cognito-idp:GetUser"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_cognito_policy.arn
}

# Also attach the AWS-managed policy for basic Lambda execution (optional, but common)
resource "aws_iam_role_policy_attachment" "attach_managed" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
