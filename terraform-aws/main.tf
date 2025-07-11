terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Environment = "test"
    Project     = "devops-challenge"
    ManagedBy   = "terraform"
    Owner       = "Joaquin"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name = "test-vpc-devops"
  cidr = "10.0.0.0/16"
  azs  = ["${var.aws_region}a", "${var.aws_region}b"]

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }

  tags = local.common_tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.29.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.27"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name            = "test-nodegroup-devops"
      instance_types  = ["t3.small"]
      min_size        = 1
      max_size        = 3
      desired_size    = 1
    }
  }

  tags = local.common_tags
}

resource "aws_s3_bucket" "html" {
  bucket = var.s3_bucket_name
  tags   = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "html" {
  bucket = aws_s3_bucket.html.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "html" {
  bucket = aws_s3_bucket.html.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_iam_role_policy" "s3_access" {
  name = "eks-s3-access"
  role = module.eks.eks_managed_node_groups["one"].iam_role_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["s3:GetObject", "s3:ListBucket", "s3:PutObject"],
        Effect   = "Allow",
        Resource = [aws_s3_bucket.html.arn, "${aws_s3_bucket.html.arn}/*"]
      }
    ]
  })
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "redis-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "test-redis-devops"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  port                 = 6379
  tags                 = local.common_tags
}
