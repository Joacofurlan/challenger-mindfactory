
variable "aws_region" {
  description = "Región de AWS"
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Nombre del cluster de EKS"
  default     = "test-eks-devops"
}

variable "s3_bucket_name" {
  description = "Nombre del bucket de S3"
  default     = "test-bucket-devops-120725"
}

variable "redis_node_type" {
  description = "Tipo de instancia para Redis"
  default     = "cache.t4g.micro"
}
