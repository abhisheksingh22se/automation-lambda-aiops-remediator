#1 Lookup Cluster
data "aws_eks_cluster" "target" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "target" {
    name = var.cluster_name
}

#2 Packaging Lambda
data "archive_file" "lambda_zip" {
    type = "zip"
    source_dir = "${path.module}/../../../src/lambda_function"
    output_path = "${path.module}/lambda_function.zip"
}

#3 Lambda Function
resource "aws_lambda_function" "remediation_func" {
  function_name = "aiops-remediation-${var.env_name}"

  filename = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = aws_iam_role.lambda_role.arn
  handler = "main.lambda_handler"
  runtime = "python3.11"

  timeout = 60

  #4 Networking (VPC Access) Commented out for testing
  # vpc_config {
  #     subnet_ids = var.subnet_ids
  #     security_group_ids = [aws_security_group.lambda_sg.id]
  # }

  #5 Environment Variables
  environment {
      variables = {
          CLUSTER_NAME = var.cluster_name
          CLUSTER_ENDPOINT = data.aws_eks_cluster.target.endpoint
          CLUSTER_CA = data.aws_eks_cluster.target.certificate_authority[0].data
          LOG_LEVEL = "INFO"
      }
  }
}

#6 Security Group
resource "aws_security_group" "lambda_sg" {
  name = "aiops-lambda-sg-${var.env_name}"
  description = "Security group for AIOps Remediation Lambda"
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

