#1 Trust Policy
resource "aws_iam_role" "lambda_role" {
  name = "aiops-remediation-role-${var.env_name}"

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

#2 Logging Policy
resource "aws_iam_role_policy_attachment" "basic_exec" {
  role = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#3 VPC Permissions
resource "aws_iam_role_policy_attachment" "vpc_access" {
  role = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

#4 EKS ReadOnly Access
resource "aws_iam_policy" "eks_describe" {
  name = "aiops-eks-describe-${var.env_name}"
  description = "Allows Lambda to describe EKS clusters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Action = [
                "eks:DescribeCluster"
            ]
            Resource = "*"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_eks_describe" {
  role = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.eks_describe.arn
}