# Knowledge Bot Infrastructure

This directory contains the Terraform configuration for the Knowledge Bot infrastructure.

## Architecture

The infrastructure consists of the following components:

- VPC with public and private subnets
- EKS cluster with Fargate profiles
- RDS PostgreSQL instance
- Application Load Balancer
- S3 bucket for document storage
- ECR repositories for container images
- CloudWatch log groups
- IAM roles and policies
- ACM certificate for HTTPS

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0.0
- kubectl
- helm

## Configuration

1. Update the `terraform.tfvars` file with your specific values:
   - `region`: AWS region
   - `environment`: Environment name (e.g., production, staging)
   - `project`: Project name
   - `domain_name`: Domain name for the application
   - `route53_zone_id`: Route53 hosted zone ID

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the planned changes:
   ```bash
   terraform plan
   ```

4. Apply the changes:
   ```bash
   terraform apply
   ```

## Modules

### VPC

- Creates a VPC with public and private subnets
- Configures NAT gateways for private subnet internet access
- Sets up route tables and network ACLs

### EKS Cluster

- Creates an EKS cluster with Fargate profiles
- Configures IAM roles and policies
- Sets up OIDC provider for service account authentication

### RDS Instance

- Creates a PostgreSQL RDS instance
- Configures security groups and subnet groups
- Sets up backup retention and monitoring

### ALB

- Creates an Application Load Balancer
- Configures HTTPS listeners with ACM certificate
- Sets up target groups and health checks

### S3 Buckets

- Creates an S3 bucket for document storage
- Configures versioning and lifecycle policies
- Sets up server-side encryption

### ECR Repositories

- Creates ECR repositories for container images
- Configures lifecycle policies
- Sets up image scanning

### CloudWatch Log Groups

- Creates log groups for application logs
- Configures retention policies
- Sets up log group tags

### IAM Roles

- Creates IAM roles for service accounts
- Configures policies for S3 access
- Sets up OIDC provider integration

### ACM Certificate

- Creates an ACM certificate
- Configures DNS validation
- Sets up certificate tags

## Outputs

The following outputs are available:

- VPC ID and CIDR block
- Subnet IDs
- EKS cluster endpoint and certificate authority data
- RDS instance endpoint
- ALB DNS name
- S3 bucket name
- ECR repository URLs
- IAM role ARNs
- ACM certificate ARN

## Security

- All resources are tagged with environment and project
- Private subnets are used for sensitive resources
- Security groups restrict access to necessary ports
- IAM roles follow the principle of least privilege
- S3 buckets have versioning and encryption enabled
- RDS instance is in a private subnet
- ALB uses HTTPS with ACM certificate

## Maintenance

- Regular Terraform plan/apply to ensure infrastructure is up to date
- Monitor CloudWatch logs for issues
- Review and update security groups as needed
- Rotate RDS credentials periodically
- Update EKS cluster version when new versions are available
- Review and update IAM policies regularly

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

Note: This will delete all resources created by Terraform. Make sure to backup any important data before running this command. 