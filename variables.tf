variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project prefix"
  type        = string
  default     = "cognito-api-auth"
}

# Location of lambda zip files for each function.
variable "lambda_signup_zip" {
  description = "Local path to signup lambda zip"
  type        = string
  default     = "lambda/signup.zip"
}
variable "lambda_signin_zip" {
  description = "Local path to signin lambda zip"
  type        = string
  default     = "lambda/signin.zip"
}
variable "lambda_getuser_zip" {
  description = "Local path to get_user lambda zip"
  type        = string
  default     = "lambda/get_user.zip"
}

variable "enable_user_pool_domain" {
  description = "Create a Cognito domain for hosted UI (optional)"
  type        = bool
  default     = false
}

variable "user_pool_domain_prefix" {
  description = "Cognito domain prefix (if enable_user_pool_domain = true)"
  type        = string
  default     = "my-auth-domain"
}

#ELB uri
variable "services" {
  type = map(string)
  default = {}
}
