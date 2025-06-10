# Doc QA Bot

A serverless knowledge bot that answers questions about documents with citations, powered by vector search and AWS Bedrock.

## Architecture

The system consists of two main microservices running on AWS EKS Fargate:

### Components

1. **Ingestor Service**
   - Kubernetes CronJob (scheduled, also invocable ad-hoc)
   - Processes documents from S3 buckets
   - Extracts and cleans text (PDF, HTML, Markdown)
   - Chunks text into ~500-token passages
   - Generates embeddings using Bedrock Titan Embed
   - Stores passages in PostgreSQL with pgvector

2. **Chat API Service**
   - Kubernetes Deployment (≥2 replicas)
   - Handles chat requests via REST API or WebSocket
   - Uses vector similarity search to find relevant passages
   - Generates answers using Bedrock Claude 3 Sonnet
   - Returns answers with citations

### Infrastructure

- **Compute**: AWS EKS with Fargate
- **Database**: RDS PostgreSQL with pgvector
- **Storage**: S3 for document storage
- **AI/ML**: AWS Bedrock for embeddings and LLM
- **Networking**: VPC with public/private subnets, ALB
- **Security**: IAM roles, security groups, TLS encryption

## Prerequisites

- AWS Account with appropriate permissions
- Terraform v1.0+
- kubectl configured
- Docker
- Python 3.8+

## Quick Start

1. **Clone the repository**
   ```bash
   git clone git@github.com:emanuel-hendriks/doc-qa-bot.git
   cd doc-qa-bot
   ```

2. **Initialize Terraform**
   ```bash
   cd infrastructure/terraform
   terraform init
   ```

3. **Configure variables**
   - Copy `terraform.tfvars.example` to `terraform.tfvars`
   - Update the variables with your values

4. **Deploy infrastructure**
   ```bash
   terraform apply
   ```

5. **Build and push Docker images**
   ```bash
   # Build images
   docker build -t doc-qa-bot/ingestor:latest src/ingestor
   docker build -t doc-qa-bot/chat-api:latest src/chat-api

   # Push to ECR
   aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_REPO
   docker push $ECR_REPO/ingestor:latest
   docker push $ECR_REPO/chat-api:latest
   ```

6. **Deploy to Kubernetes**
   ```bash
   kubectl apply -f infrastructure/kubernetes/
   ```

## Usage

### Adding Documents

1. Upload documents to the S3 bucket:
   ```bash
   aws s3 cp your-document.pdf s3://your-docs-bucket/
   ```

2. Trigger ingestion:
   ```bash
   kubectl create job --from=cronjob/ingestor ingestor-manual-001
   ```

### Asking Questions

Send a POST request to the chat API:
```bash
curl -X POST https://your-domain/chat \
  -H "Content-Type: application/json" \
  -H "x-api-key: your-api-key" \
  -d '{"question": "Your question here"}'
```

Response format:
```json
{
  "answer": "The answer to your question...",
  "citations": [
    {
      "file": "source-document.pdf",
      "page": 42,
      "snippet": "Relevant text snippet..."
    }
  ]
}
```

## Cost Optimization

The infrastructure is designed to be cost-effective:
- RDS Serverless v2 for database
- EKS Fargate for compute
- Auto-scaling based on demand
- S3 lifecycle policies for storage optimization

Estimated monthly cost: ~€80-85

## Security

- All components run in private subnets
- TLS encryption for all communications
- IAM roles for service accounts (IRSA)
- Security groups with least privilege
- Optional WAF protection

## Maintenance

- Regular security updates
- Database backups
- Log monitoring via CloudWatch
- Health checks and auto-recovery

## License

MIT License - see LICENSE file for details 