terraform {
  required_version = ">= 0.13"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
  required_version = ">= 0.13"
}

provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.graph-indexer.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.graph-indexer.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.graph-indexer.name]
      command     = "aws"
    }
  }
}
