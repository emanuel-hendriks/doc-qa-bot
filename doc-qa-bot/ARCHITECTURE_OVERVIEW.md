# Doc QA Bot: Architecture Overview

This document provides a comprehensive overview of the Doc QA Bot project's architecture, emphasizing its GitOps-driven approach and the structured separation into three distinct Git repositories.

## 1. Project Introduction

The **Doc QA Bot** is a serverless knowledge bot designed to answer free-form questions about documents stored in an S3 bucket, providing fluent answers with explicit citations. It leverages a vector database (PostgreSQL + pgvector) and Amazon Bedrock for language model operations. The entire infrastructure is declared in Terraform, and application deployments are managed via Helm charts on Amazon EKS Fargate.

## 2. Architectural Philosophy: GitOps and Separation of Concerns

To achieve high velocity, reliability, and clear ownership, the Doc QA Bot project adopts a GitOps methodology. This approach treats Git as the single source of truth for declarative infrastructure and application states. A core principle of this architecture is the strict separation of concerns into dedicated repositories, enabling independent development, testing, and deployment workflows.

### Benefits of this Approach:

*   **Clear Ownership:** Different teams or roles can own specific aspects of the project (e.g., developers for application, SREs for infrastructure, DevOps for Kubernetes deployments).
*   **Independent Versioning & Release Cycles:** Each component can evolve and be released at its own pace without direct coupling to others.
*   **Enhanced Security:** Granular access controls can be applied to each repository, enforcing least privilege.
*   **Auditability & Traceability:** Every change is a Git commit, providing a complete history and rollback capability.
*   **Automated Reconciliation:** GitOps operators can continuously monitor the repositories and automatically apply changes to the target environment, ensuring desired state.

## 3. Repository Breakdown and Inter-relationships

1.  **`doc-qa-bot-application-code` (Application Code Repository)

    *   **Purpose:** Houses the core Python source code for the Doc QA Bot's microservices.
    *   **Key Contents:**
        *   `src/chat-api/`: Source code for the Chat API service (handles user queries).
        *   `src/ingestor/`: Source code for the Ingestor service (processes documents).
        *   `scripts/`: Utility scripts.
        *   `docs/`: Application-specific architectural documentation.
        *   `requirements.txt`: Python dependencies.
    *   **Role in Architecture:** This repository is where the application logic resides. Changes here drive new feature development and bug fixes for the core bot functionality.
    *   **Relationships:**
        *   **Input to:** `doc-qa-bot-kubernetes-helm-charts` (Docker images built from this repo are referenced by Helm charts).
        *   **Depends on:** `doc-qa-bot-infrastructure-code` (relies on AWS services like ECR, Bedrock, RDS provisioned by the infrastructure).

2.  **`doc-qa-bot-infrastructure-code` (Infrastructure Code Repository)

    *   **Purpose:** Contains all Terraform configurations for provisioning and managing the AWS cloud infrastructure.
    *   **Key Contents:**
        *   `main.tf`, `variables.tf`, `outputs.tf`: Core Terraform configuration.
        *   `modules/`: Reusable Terraform modules for specific AWS services (VPC, EKS, RDS, S3, IAM, ECR, etc.).
        *   `backend/`: Terraform state backend configuration.
        *   `environments/`: Environment-specific (e.g., `dev`, `prod`) infrastructure configurations.
        *   `todos.md`: Infrastructure development roadmap/tasks.
    *   **Role in Architecture:** This repository forms the foundation of the environment. Any change to the underlying AWS resources (e.g., VPC CIDR, EKS version, RDS instance type) is managed here.
    *   **Relationships:**
        *   **Output to:** `doc-qa-bot-kubernetes-helm-charts` (provisions the EKS cluster where Helm charts deploy, and outputs necessary cluster details, ECR URLs, IAM role ARNs for Helm chart consumption).
        *   **Supports:** `doc-qa-bot-application-code` (provides the AWS resources the application services consume).

3.  **`doc-qa-bot-kubernetes-helm-charts` (Kubernetes/Helm Charts Repository)

    *   **Purpose:** Holds the Helm charts that define the desired state of Kubernetes resources for deploying the Doc QA Bot microservices onto the EKS cluster.
    *   **Key Contents:**
        *   `helm/chat-api/`: Helm chart for the Chat API deployment.
        *   `helm/ingestor/`: Helm chart for the Ingestor deployment (including CronJob).
        *   `helm/load-balancer-controller/`: Helm chart for deploying the AWS Load Balancer Controller.
    *   **Role in Architecture:** This repository acts as the bridge between the application code and the infrastructure. It specifies *how* the application services should run on Kubernetes.
    *   **Relationships:**
        *   **Depends on:** `doc-qa-bot-application-code` (pulls Docker images from ECR, whose names/tags are defined here).
        *   **Depends on:** `doc-qa-bot-infrastructure-code` (deploys to the EKS cluster provisioned by the infrastructure, and uses outputs from the infrastructure such as ECR repository URLs, security group IDs, IAM role ARNs, etc.).

## 4. End-to-End GitOps Workflow

1.  **Application Development (`doc-qa-bot-application-code`):** Developers commit code changes to the application repository.
2.  **CI Pipeline:** A CI pipeline builds Docker images (Ingestor, Chat API) from the application code and pushes them to ECR repositories (provisioned by the infrastructure).
3.  **Infrastructure Provisioning (`doc-qa-bot-infrastructure-code`):** Infrastructure engineers manage Terraform code to provision or update AWS resources. Changes are applied (often manually approved for `terraform apply`) to create or modify the EKS cluster, databases, S3 buckets, etc.
4.  **Deployment Definition (`doc-qa-bot-kubernetes-helm-charts`):** DevOps/SREs update Helm chart values or templates to specify desired application versions (image tags), Kubernetes resource configurations, or other deployment parameters. This includes referencing the Docker images pushed in step 2.
5.  **GitOps Reconciliation:** A GitOps operator (e.g., Argo CD, Flux CD) continuously monitors the `kubernetes-helm-charts` repository. Upon detecting changes, it automatically applies these Helm chart definitions to the target EKS cluster (provisioned in step 3).
6.  **Application Runtime:** The deployed application services run on EKS Fargate, interacting with RDS, Bedrock, and S3, forming the functional Doc QA Bot.

## 5. Conclusion

This GitOps-driven architecture, with its clear separation of application code, infrastructure code, and Kubernetes configurations, provides a robust, scalable, and maintainable foundation for the Doc QA Bot. It promotes efficient team collaboration, secure deployments, and an auditable development lifecycle. 