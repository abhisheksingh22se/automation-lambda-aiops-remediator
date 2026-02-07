# Infrastructure Inputs
variable "aws_region" {
  description = "The AWS region where resources will be created"
  type = string
}

variable "cluster_name" {
  description = "The name of the existing EKS cluster to monitor & manage"
  type = string
}

variable "vpc_id" {
  description = "The VPC ID where the EKS cluster lives"
  type = string
}

variable "subnet_ids" {
  description = "List of Private Subnet IDs where the Lambda function will run"
  type = list(string)
}

# Configuration Inputs
variable "env_name" {
  description = "Environment label (dev/prod)"
  type = string
}

variable "cpu_threshold" {
  description = "The CPU % at which the CloudWatch Alarm should fire"
  type = number
  default = 80
}

variable "log_retention" {
  description = "How many days to keep the Lambda logs in CloudWatch"
  type = number
  default = 14
}