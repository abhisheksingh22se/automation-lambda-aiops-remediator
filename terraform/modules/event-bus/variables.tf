variable "target_lambda_arn" {
  description = "The ARN of the Lambda function to trigger"
  type = string
}

variable "target_lambda_name" {
  description = "The Name of the Lambda function"
  type = string
}

variable "trigger_alarm_names" {
  description = "List of Alarm Names that should trigger the bus"
  type = list(string)
}