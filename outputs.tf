
output "api_invoke_url" {
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.stage.stage_name}"
  description = "Invoke URL for the API (note: stage is appended)"
}

# For REST APIs, you can also output the root invoke URL:
output "api_root_invoke_url" {
  value = aws_api_gateway_rest_api.api.execution_arn
}
