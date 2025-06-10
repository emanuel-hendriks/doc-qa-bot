output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "List of IDs of private app subnets"
  value       = module.vpc.private_app_subnet_ids
}

output "private_data_subnet_ids" {
  description = "List of IDs of private data subnets"
  value       = module.vpc.private_data_subnet_ids
}

output "cluster_endpoint" {
  description = "The endpoint for the Kubernetes API server"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks_cluster.cluster_certificate_authority_data
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks_cluster.cluster_name
}

output "db_instance_endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = module.rds_instance.db_instance_endpoint
}

output "db_instance_name" {
  description = "The database name"
  value       = module.rds_instance.db_instance_name
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.alb_dns_name
}

output "docs_bucket_name" {
  description = "The name of the S3 bucket for documents"
  value       = module.s3_buckets.docs_bucket_id
}

output "repository_urls" {
  description = "The URLs of the ECR repositories"
  value       = module.ecr.repository_urls
}

output "ingestor_role_arn" {
  description = "The ARN of the ingestor IAM role"
  value       = module.iam.ingestor_role_arn
}

output "chat_api_role_arn" {
  description = "The ARN of the chat API IAM role"
  value       = module.iam.chat_api_role_arn
}

output "certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = module.acm.certificate_arn
}

output "route53_name_servers" {
  description = "The name servers for the Route53 hosted zone. Use these to configure your domain registrar."
  value       = module.route53.name_servers
}

output "route53_zone_id" {
  description = "The ID of the Route53 hosted zone"
  value       = module.route53.zone_id
} 