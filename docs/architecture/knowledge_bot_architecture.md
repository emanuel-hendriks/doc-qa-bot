# Quick‑Start Knowledge Bot on AWS EKS Fargate

## 1  What the project is
A **Knowledge‑Bot** service that lets users ask free‑form questions about any set of documents placed in an S3 bucket and receive fluent answers **with explicit citations**.  
It is built as two micro‑services running on **Amazon EKS Fargate**, backed by a **vector database** (PostgreSQL + pgvector) and **Amazon Bedrock** for all language‑model calls.  
Everything—network, security, roles, pods, and database—is declared in Terraform.

---

## 2  How the application works (end‑to‑end)

### 2.1  Runtime components

| Component | Kind | Responsibility | AWS calls it makes |
|-----------|------|----------------|--------------------|
| **Ingestor** | Kubernetes **CronJob** (scheduled; also invocable ad‑hoc) | • Enumerate new objects in `docs-raw-*` bucket<br>• Extract & clean text (PDF, HTML, Markdown)<br>• Chunk into ≈ 500‑token passages<br>• Request embeddings from **Bedrock Titan Embed Text**<br>• `UPSERT` passage rows `(id, text, metadata, vector)` into pgvector | S3 `GetObject`, Bedrock `InvokeModel`, RDS (TCP 5432) |
| **Chat‑API** | Kubernetes **Deployment** (≥ 2 replicas) | • Accept `/chat` POST or WebSocket<br>• Compute user‑query embedding via Bedrock Embed (cached 30 min)<br>• `SELECT … ORDER BY vector <=> :q LIMIT k` against pgvector<br>• Craft prompt and call **Bedrock Claude 3 Sonnet** (or Llama 3 70B)<br>• Stream `{answer, citations}` JSON back to client | Bedrock `InvokeModel`, RDS (TCP 5432) |

Both containers are ~150 MB images (`ingestor:latest`, `chat-api:latest`) pushed to **Amazon ECR**.

---

### 2.2  IAM integration (least privilege)

* **IRSA** (IAM Roles for Service Accounts) binds:

| Role | Bound SA | Key IAM permissions |
|------|----------|---------------------|
| `IngestorRole` | `ingestor-sa` | `s3:GetObject`, `bedrock:InvokeModel`, `secretsmanager:GetSecretValue`, `rds-db:connect` |
| `ChatApiRole`  | `chat-sa`     | `bedrock:InvokeModel`, `rds-db:connect`, `secretsmanager:GetSecretValue` |

No node roles or long‑lived keys; every Bedrock call is signed with temporary pod credentials.

---

### 2.3  Networking & security groups

```text
Client ──TLS 443──► ALB  (SG: 443 in from 0.0.0.0/0)
                    │
                    ▼  (Kubernetes Ingress)
              chat‑api pods  (Fargate ENI, SG: allow 443 from ALB SG; 5432 egress → RDS SG)
                    │
          TLS 5432  ▼
              RDS PostgreSQL  (SG: allow 5432 from chat‑api SG only)

Outbound (via NAT Gateway):
   chat‑api & ingestor ──► HTTPS 443 → Bedrock regional endpoint
   ingestor only       ──► HTTPS 443 → S3 bucket endpoint
```

* **Encryption everywhere**: ACM certificate at ALB; pods serve HTTPS; RDS enforces `sslmode=require`.  
* **Isolation**: public subnet hosts ALB/NAT/IGW, private‑app subnets host Fargate ENIs, private‑data subnets host RDS.  
* **Optional WAF**: attach `aws_wafv2_web_acl` to ALB or lock its SG to corporate CIDRs/VPN.

---

### 2.4  Application start‑up sequence

1. **`terraform apply`**  
   * Creates VPC, subnets, NAT/IGW, EKS, Fargate profile, ALB, RDS, Secrets Manager, and ECR.  
   * Deploys Helm chart installing the Load Balancer Controller and namespaces `ingestion` + `api`.
2. **Database bootstrap** runs `init.sql` via Terraform:  
   `CREATE EXTENSION IF NOT EXISTS pgvector;` then create `passages` table.
3. **First ingestion run**  
   ```bash
   kubectl create job --from=cronjob/ingestor ingestor-manual-001
   ```
   populates the vector store.
4. **Pods ready** – ALB health‑checks `/healthz`; Route 53 CNAME `kb-demo.yourdomain` goes live.

---

### 2.5  Normal request–response flow

1. **User** sends  
   ```json
   { "question": "How do I tag an EC2 instance?" }
   ```  
   to `https://kb-demo.yourdomain/chat` with an `x-api-key` header (or Cognito JWT).
2. **ALB** terminates TLS, verifies WAF/OIDC, forwards to K8s Ingress.
3. **chat‑api** pod embeds question → retrieves passages → prompts Claude/Llama → streams
   ```json
   {
     "answer": "Open the AWS console, select your instance, choose Tags …",
     "citations": [
       { "file": "aws_basics.pdf", "page": 32, "snippet": "Select Tags …" }
     ]
   }
   ```
4. **Client** renders answer; each citation opens the exact page in a new tab.

---

## 3  How users are expected to interact

### 3.1  Baseline (no front‑end)

* HTTPS REST API.  
* Auth: single API key in `x-api-key`; middleware returns 401 on failure.

### 3.2  Optional thin UI

* Static React bundle served by FastAPI at `/`.  
* If Cognito is enabled, Amplify Auth obtains a JWT and attaches it to requests.

---

## 4  Enumerated AWS resources

| Terraform logical name | Function |
|------------------------|----------|
| `aws_vpc.main` | Base network (10.0.0.0/16) |
| `aws_subnet.public_a` / `public_b` | Host ALB, NAT, IGW |
| `aws_subnet.private_app_a` / `b` | Host Fargate ENIs |
| `aws_subnet.private_data_a` / `b` | Host RDS instance |
| `aws_nat_gateway.ngw` | Allows private subnets egress |
| `aws_eks_cluster.this` | Kubernetes control plane |
| `aws_eks_fargate_profile.fp` | Schedules pods on Fargate |
| `aws_lb.alb` & `aws_lb_target_group.chat` | Public HTTPS entry point |
| `aws_acm_certificate.ssl_cert` | TLS cert for `kb-demo.yourdomain` |
| `aws_security_group.alb_sg` | 443 in from the world → ALB |
| `aws_security_group.pod_sg` | 443 in from ALB SG; 0‑egress |
| `aws_security_group.rds_sg` | 5432 in from pod SG |
| `aws_db_instance.pgvector` | PostgreSQL 16 with pgvector |
| `aws_s3_bucket.docs_raw` | Source documents |
| `aws_secretsmanager_secret.rds_creds` | DB password |
| `aws_iam_openid_connect_provider.eks_oidc` | Enables IRSA |
| `aws_iam_role.ingestor_role` / `chat_role` | Pod IAM permissions |
| `aws_ecr_repository.ingestor_repo` / `chat_repo` | Container images |
| `aws_cloudwatch_log_group.ingestor` / `chat` | Centralised logs |
| `kubernetes_cron_job.ingestor` | Scheduled document ingestion |
| `kubernetes_deployment.chat_api` | User‑facing API |

---

## 5  Key take‑aways

* **Fully reproducible** – one Terraform apply, two Docker images.  
* **Serverless footprint** – no EC2 nodes or GPUs to manage.  
* **Security‑first defaults** – private subnets, IRSA, TLS, optional WAF.  
* **Rapid feedback** – drop a file in S3, ask a question a minute later.
