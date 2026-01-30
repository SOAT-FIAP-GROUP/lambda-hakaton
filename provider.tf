terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  required_version = ">= 1.0"
  backend "s3" {
     bucket         = "meu-terraform-states-soat-948512815388"
     key            = "env:/dev/lambda/terraform.tfstate"
     region         = "us-east-1"
     dynamodb_table = "terraform-locks-soat"
  }
}

provider "aws" {
  region = var.aws_region
}
