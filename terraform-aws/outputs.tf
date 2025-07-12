
output "cluster_endpoint" {
  description = "Endpoint del cluster EKS test devops"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Cluster EKS test devops"
  value       = var.cluster_name
}

output "s3_bucket" {
  description = "Bucket S3 test devops"
  value       = var.s3_bucket_name
}

output "eks_iam_role_name" {
  description = "IAM role de los nodos EKS (acceso S3)"
  value       = module.eks.eks_managed_node_groups["one"].iam_role_name
}

output "eks_node_security_group_id" {
  description = "Security Group ID de los nodos EKS"
  value       = module.eks.node_security_group_id
}

output "redis_endpoint" {
  description = "Endpoint del Redis test devops"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_port" {
  description = "Puerto para conectarse al Redis"
  value       = aws_elasticache_cluster.redis.port
}
