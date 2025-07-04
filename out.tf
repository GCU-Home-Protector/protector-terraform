output "public_ip" {
  value       = aws_instance.eks_bastion.public_ip
  description = "The public IP of the myeks-host EC2 instance."
}

output "master_rds_endpoint" {
  value       = aws_db_instance.primary_rds.endpoint
  description = "The endpoint of the primary RDS instance."
}

output "slave_rds_endpoint" {
    value       = aws_db_instance.read_replica.endpoint
    description = "The endpoint of the read replica RDS instance."
}

output "elasticache_endpoint" {
  value       = aws_elasticache_serverless_cache.elasticache.endpoint
  description = "The endpoint of the ElastiCache cluster."
}

output "k6_endpoint" {
  value = aws_instance.k6_instance.public_ip
  description = "Public IP of K6 host"
}
