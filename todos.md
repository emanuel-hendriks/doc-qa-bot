# Infrastructure Todo List

## 1. VPC and Networking
- [ ] Implement VPC module with:
  - [ ] Public subnets for ALB, NAT, IGW
  - [ ] Private app subnets for Fargate ENIs
  - [ ] Private data subnets for RDS
  - [ ] NAT Gateway configuration
  - [ ] Internet Gateway
  - [ ] Route tables and associations

## 2. EKS Cluster
- [ ] Configure EKS cluster module with:
  - [ ] Fargate profile
  - [ ] OIDC provider setup
  - [ ] Node groups (if needed)
  - [ ] Cluster add-ons (CoreDNS, kube-proxy, etc.)
  - [ ] IRSA integration with our IAM roles
  - [ ] Load Balancer Controller installation
  - [ ] Create namespaces:
    - [ ] ingestion
    - [ ] api

## 3. Load Balancer and Security
- [ ] Implement ALB module:
  - [ ] Application Load Balancer
  - [ ] Target Groups
  - [ ] Listener rules
  - [ ] Health checks
- [ ] Configure ACM module:
  - [ ] SSL certificate
  - [ ] Domain validation
- [ ] Set up Security Groups:
  - [ ] ALB security group (443 inbound)
  - [ ] Pod security group (443 from ALB)
  - [ ] RDS security group (5432 from pods)

## 4. Database
- [ ] Configure RDS module:
  - [ ] PostgreSQL 16 instance
  - [ ] pgvector extension
  - [ ] SSL configuration
  - [ ] Parameter group for pgvector
  - [ ] Subnet group in private data subnets
  - [ ] Database initialization script:
    - [ ] pgvector extension creation
    - [ ] passages table creation
  - [ ] Backup configuration

## 5. Storage and Secrets
- [ ] Set up S3 buckets:
  - [ ] Source documents bucket
  - [ ] Access logging
  - [ ] Lifecycle policies
  - [ ] Bucket policy
  - [ ] CORS configuration (if needed)
- [ ] Configure Secrets Manager:
  - [ ] RDS credentials
  - [ ] API keys
  - [ ] Access policies

## 6. Container Registry
- [ ] Implement ECR module:
  - [ ] Ingestor repository
  - [ ] Chat API repository
  - [ ] Repository policies
  - [ ] Lifecycle policies

## 7. Monitoring and Logging
- [ ] Set up CloudWatch module:
  - [ ] Log groups for Ingestor
  - [ ] Log groups for Chat API
  - [ ] Log retention policies
  - [ ] Metrics and alarms

## 8. Kubernetes Resources
- [ ] Create Kubernetes manifests:
  - [ ] Namespaces (ingestion, api)
  - [ ] Service accounts
  - [ ] CronJob for Ingestor
  - [ ] Deployment for Chat API
  - [ ] Ingress configuration
  - [ ] ConfigMaps and Secrets
  - [ ] Health check endpoint (`/healthz`)
  - [ ] Resource limits and requests for pods
  - [ ] Service account configurations for IRSA

## 9. DNS and Routing
- [ ] Implement Route 53 module:
  - [ ] Hosted zone
  - [ ] DNS records for ALB
  - [ ] Certificate validation records

## 10. Optional Components
- [ ] Configure WAF module:
  - [ ] Web ACL
  - [ ] Rule groups
  - [ ] IP sets
- [ ] Set up Cognito (if needed):
  - [ ] User pool
  - [ ] App client
  - [ ] Domain configuration

## 11. Main Configuration
- [ ] Update main Terraform configuration:
  - [ ] Provider configuration
  - [ ] Module integration
  - [ ] Variable definitions
  - [ ] Output definitions
- [ ] Create environment-specific configurations:
  - [ ] Dev environment
  - [ ] Prod environment
  - [ ] Staging environment

## 12. Documentation and Testing
- [ ] Add module documentation:
  - [ ] Input variables
  - [ ] Output values
  - [ ] Usage examples
- [ ] Create test configurations:
  - [ ] Unit tests
  - [ ] Integration tests
- [ ] Add README with:
  - [ ] Architecture overview
  - [ ] Deployment instructions
  - [ ] Maintenance procedures