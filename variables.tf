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


#ELB uri
variable "services" {
  type = map(string)
  default = {}
}
