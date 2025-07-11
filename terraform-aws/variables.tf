# variables.tf 

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "cluster_name" {
  description = "Nombre del cluster EKS"
  type        = string
  default     = "test-eks-devops"
}

variable "s3_bucket_name" {
  description = "Nombre del bucket S3"
  type        = string
  default     = "test-bucket-devops-100725"
}

variable "redis_cluster_id" {
  description = "ID of the Redis cluster"
  type        = string
  default     = "test-redis-devops"
}

variable "redis_node_type" {
  description = "Instance type for Redis"
  type        = string
  default     = "cache.t3.micro"
}