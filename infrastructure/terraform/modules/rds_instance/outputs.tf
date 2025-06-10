output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.this.id
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.this.address
}

output "endpoint" {
  description = "The connection endpoint for the RDS cluster"
  value       = aws_rds_cluster.this.endpoint
}

output "database_name" {
  description = "The database name"
  value       = aws_rds_cluster.this.database_name
}

output "master_username" {
  description = "The master username for the database"
  value       = aws_rds_cluster.this.master_username
  sensitive   = true
}

output "port" {
  description = "The database port"
  value       = aws_rds_cluster.this.port
}

output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = aws_db_subnet_group.this.id
}

output "db_security_group_id" {
  description = "The security group ID of the RDS instance"
  value       = aws_security_group.rds.id
}

output "cluster_identifier" {
  description = "The RDS cluster identifier"
  value       = aws_rds_cluster.this.cluster_identifier
} 