#1 The ID Card (ARN)
output "lambda_arn" {
  description = "The ARN of the remediation Lambda function"
  value = aws_lambda_function.remediation_func.arn
}

#2 The Name
output "lambda_name" {
  description = "The Name of the remediation Lambda function"
  value = aws_lambda_function.remediation_func.function_name
}

#3 kubectl aws-auth
output "lambda_role_arn" {
  description = "The ARN of the IAM Role (Needed for aws-auth ConfigMap)"
  value       = aws_iam_role.lambda_role.arn
}