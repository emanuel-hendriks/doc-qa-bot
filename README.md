# Knowledge Bot Infrastructure

This repository contains the Terraform configuration for deploying the Knowledge Bot infrastructure on AWS.

## Architecture

The infrastructure includes:
- EKS Cluster with Fargate profiles
- RDS Serverless v2 (Aurora PostgreSQL)
- S3 buckets for document storage
- Application Load Balancer
- Route53 DNS configuration
- VPC with public and private subnets
- NAT Gateway for outbound internet access
- CloudWatch Logs for monitoring

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform v1.0.0 or later
- kubectl for Kubernetes interaction

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Create a `terraform.tfvars` file with your configuration:
```hcl
aws_region = "eu-south-1"
domain_name = "your-domain.com"
# Add other required variables
```

3. Plan the deployment:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

## Cost Optimization

The infrastructure is optimized for cost:
- RDS Serverless v2 with 0.5-1.0 ACU
- Single NAT Gateway
- Auto-scaling Fargate profiles
- S3 lifecycle policies for cost-effective storage

Estimated monthly cost: ~€80-85

## Security

- All resources are deployed in a VPC
- Private subnets for sensitive resources
- Security groups with minimal required access
- RDS in private subnet
- S3 buckets with encryption and public access blocked

## Maintenance

- Regular backups of RDS (3-day retention)
- CloudWatch monitoring
- Auto-scaling based on CPU and memory utilization

## License

MIT 