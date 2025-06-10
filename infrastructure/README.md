# Doc QA Bot Infrastructure

Terraform configuration for deploying the Doc QA Bot infrastructure on AWS.

## Infrastructure Components

### Network Layer
- VPC (10.0.0.0/16) with:
  - 2 Public Subnets (for ALB, NAT Gateway)
  - 2 Private App Subnets (for EKS Fargate)
  - 2 Private Data Subnets (for RDS)
  - NAT Gateway for outbound internet access
  - Internet Gateway for public access

### Compute Layer
- EKS Cluster (v1.28)
  - Fargate Profile for serverless compute
  - Auto-scaling configuration:
    - Min: 1 pod
    - Max: 2 pods
    - Target CPU: 80%
    - Target Memory: 80%

### Database Layer
- RDS Serverless v2 (PostgreSQL 16)
  - Min ACU: 0.5
  - Max ACU: 1.0
  - Storage: 5GB
  - Backup retention: 3 days
  - pgvector extension enabled

### Storage Layer
- S3 Buckets:
  - `docs-raw-*`: Source documents
  - `docs-processed-*`: Processed content
  - Lifecycle policies:
    - Transition to IA after 30 days
    - Delete after 90 days

### Security Layer
- IAM Roles:
  - `IngestorRole`: S3, Bedrock, RDS access
  - `ChatApiRole`: Bedrock, RDS access
- Security Groups:
  - ALB: 443 inbound from 0.0.0.0/0
  - Pod: 443 inbound from ALB, 5432 outbound to RDS
  - RDS: 5432 inbound from Pod SG
- WAF (Optional):
  - Rate limiting
  - SQL injection protection
  - XSS protection

### Monitoring Layer
- CloudWatch:
  - Log groups for each service
  - Metrics for:
    - CPU/Memory utilization
    - Request latency
    - Error rates
  - Alarms for:
    - High error rates
    - High latency
    - Resource exhaustion

## Cost Breakdown

Monthly estimated costs:
- EKS Fargate: ~€20-25
- RDS Serverless: ~€5-10
- NAT Gateway: ~€35
- Other Services: ~€20-25
  - S3: ~€1-2
  - ECR: ~€1-2
  - Route53: ~€0.50
  - CloudWatch: ~€1-2
  - ALB: ~€20

Total: ~€80-85/month

## Prerequisites

- AWS CLI configured
- Terraform v1.0+
- kubectl
- AWS Account with permissions for:
  - EKS
  - RDS
  - S3
  - IAM
  - VPC
  - Bedrock

## Usage

1. **Initialize Terraform**
   ```bash
   terraform init
   ```

2. **Configure variables**
   ```hcl
   # terraform.tfvars
   aws_region = "eu-south-1"
   environment = "prod"
   domain_name = "your-domain.com"
   vpc_cidr = "10.0.0.0/16"
   ```

3. **Deploy**
   ```bash
   terraform plan
   terraform apply
   ```

4. **Verify deployment**
   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

## Maintenance

- Regular security updates
- Database backups (3-day retention)
- Log rotation
- Cost monitoring
- Security group audits

## Security Notes

- All resources in private subnets
- TLS encryption everywhere
- IAM roles with least privilege
- Regular security group reviews
- Optional WAF for additional protection

## License

MIT License - see LICENSE file for details 