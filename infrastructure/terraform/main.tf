terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_name, "--region", var.region]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_name, "--region", var.region]
    }
  }
}

# VPC and Networking
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_app_cidrs    = var.private_app_cidrs
  private_data_cidrs   = var.private_data_cidrs
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  project             = var.project

  tags = var.tags
}

# EKS Cluster
module "eks_cluster" {
  source = "./modules/eks_cluster"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_app_subnet_ids

  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "kube-system"
        }
      ]
    }
    ingestion = {
      name = "ingestion"
      selectors = [
        {
          namespace = "ingestion"
        }
      ]
    }
    api = {
      name = "api"
      selectors = [
        {
          namespace = "api"
        }
      ]
    }
  }

  tags = var.tags
}

# Security Groups
module "security_groups" {
  source = "./modules/security_groups"

  vpc_id  = module.vpc.vpc_id
  project = var.project

  tags = var.tags
}

# RDS Instance
module "rds_instance" {
  source = "./modules/rds_instance"

  identifier        = "${var.project}-db"
  engine_version    = "16"
  instance_class    = var.rds_instance_class
  allocated_storage = var.rds_allocated_storage
  db_name          = "knowledgebot"
  username         = "admin"
  password         = "changeme" # TODO: Use AWS Secrets Manager

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_data_subnet_ids

  security_group_rules = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  ]

  tags = var.tags
}

# ALB
module "alb" {
  source = "./modules/alb"

  name               = "${var.project}-alb"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.alb_sg_id
  certificate_arn   = module.acm.certificate_arn

  tags = var.tags
}

# S3 Buckets
module "s3_buckets" {
  source = "./modules/s3_buckets"

  docs_bucket_name = var.docs_bucket_name

  tags = var.tags
}

# ECR Repositories
module "ecr" {
  source = "./modules/ecr"

  repositories = ["ingestor", "chat-api"]

  tags = var.tags
}

# CloudWatch Log Groups
module "cloudwatch" {
  source = "./modules/cloudwatch"

  project     = var.project
  environment = var.environment
  log_groups = {
    ingestor = {
      name              = "/aws/eks/${var.cluster_name}/ingestor"
      retention_in_days = 7
    }
    chat_api = {
      name              = "/aws/eks/${var.cluster_name}/chat-api"
      retention_in_days = 7
    }
  }

  tags = var.tags
}

# IAM Roles
module "iam" {
  source = "./modules/iam"

  cluster_name      = module.eks_cluster.cluster_name
  oidc_arn         = module.eks_cluster.oidc_provider_arn
  docs_bucket_name = var.docs_bucket_name

  tags = var.tags
}

# Route53
module "route53" {
  source = "./modules/route53"

  domain_name = var.domain_name
  tags        = var.tags
}

# ACM Certificate
module "acm" {
  source = "./modules/acm"

  domain_name      = var.domain_name
  route53_zone_id  = module.route53.zone_id
  tags            = var.tags
} 