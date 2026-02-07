output "remediation_role_arn" {
  description = "the ARN of the remediation Lambda IAM Role"
  value       = module.aiops_remediation.lambda_role_arn
}

output "lambda_function_name" {
  description = "The name of the remediation Lambda function"
  value = module.aiops_remediation.lambda_name
}