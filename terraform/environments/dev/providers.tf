terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    archive = {
      source = "hashicorp/archive"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

# Lookup your EXISTING Dev Cluster
data "aws_eks_cluster" "dev_cluster" {
  name = "eks-infra-cluster" # Replace this with your actual Cluster Name
}

data "aws_eks_cluster_auth" "dev_cluster" {
  name = "eks-infra-cluster" # Replace this with your actual Cluster Name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.dev_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.dev_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.dev_cluster.token
}