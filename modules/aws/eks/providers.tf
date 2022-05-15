terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.0.2"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.0.2"
    }

    random = {
      source  = "hashicorp/random"
      version = "2.3.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "1.4.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "2.1.2"
    }

    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}


