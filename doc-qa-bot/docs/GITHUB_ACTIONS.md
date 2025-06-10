# GitHub Actions Workflows: CI/CD Guide

This document describes the GitHub Actions workflows implemented across the Doc QA Bot project repositories. These workflows are integral to our GitOps strategy, automating the continuous integration and continuous delivery processes for both infrastructure and application deployments.

## 1. Introduction to GitHub Actions and GitOps

GitHub Actions provide a flexible and powerful way to automate workflows directly within your GitHub repositories. In a GitOps context, these actions are used to ensure that all changes to infrastructure or application code (defined declaratively in Git) are automatically validated, built, and eventually applied to the target environments.

## 2. Secure AWS Authentication with OpenID Connect (OIDC)

To securely interact with AWS services from GitHub Actions, we utilize OpenID Connect (OIDC) instead of long-lived AWS Access Keys. This enhances security by allowing GitHub Actions runners to assume temporary IAM roles in your AWS account.

### How OIDC Works:

1.  **GitHub Issues a Token:** When a workflow runs, GitHub automatically generates a JSON Web Token (JWT) with claims about the workflow, repository, and job.
2.  **AWS OIDC Provider:** An IAM OIDC Identity Provider in your AWS account trusts `token.actions.githubusercontent.com`.
3.  **AssumeRoleWithWebIdentity:** The GitHub Actions `aws-actions/configure-aws-credentials` action uses the JWT to call AWS STS `AssumeRoleWithWebIdentity`, requesting temporary credentials for a pre-configured IAM role.
4.  **Permissions by Role:** The assumed IAM role has specific permissions required for the workflow's tasks.

### AWS IAM Setup (Prerequisites - managed by `doc-qa-bot-infrastructure-code`):

*   **IAM OIDC Provider:**
    *   **URL:** `https://token.actions.githubusercontent.com`
    *   **Audience:** `sts.amazonaws.com`
    *   (The `thumbprint_list` is managed automatically by Terraform)
*   **IAM Role for Application Push (`GitHubActionsOIDCAppPushRole`):**
    *   **Trust Policy Condition:** Allows assumption only by workflows from `doc-qa-bot-application-code` (e.g., `repo:emanuel-hendriks/doc-qa-bot-application-code:ref:refs/heads/main` or `repo:emanuel-hendriks/doc-qa-bot-application-code:*` for all branches).
    *   **Permissions:** Grants `ecr:Push`, `ecr:GetAuthorizationToken`, and other necessary ECR permissions to push Docker images.
*   **IAM Role for Infrastructure Management (`GitHubActionsOIDCInfraRole`):**
    *   **Trust Policy Condition:** Allows assumption only by workflows from `doc-qa-bot-infrastructure-code`.
    *   **Permissions:** Grants the necessary permissions for Terraform to validate, plan, and apply changes to your AWS resources (e.g., S3 for state, EKS, RDS, VPC, etc.). **(Note: This role's permissions must be meticulously scoped down in production for least privilege).**

## 3. Infrastructure CI/CD Workflow (`doc-qa-bot-infrastructure-code`)

*   **Workflow File:** `infrastructure-code/.github/workflows/terraform.yml`
*   **Purpose:** Automates the testing and application of Terraform infrastructure changes.
*   **Triggers:**
    *   `pull_request` merged to `main` branch.
*   **Jobs:**
    *   `terraform_plan`:
        *   Runs on `pull_request` (before merge).
        *   Performs `terraform init`, `terraform validate`, and `terraform plan`.
        *   Uploads the `tfplan` artifact, which is the proposed infrastructure change.
    *   `terraform_apply`:
        *   **Requires manual approval** (if `production` environment is configured in GitHub for approvals).
        *   Runs only on `pull_request` merge to `main` (after `terraform_plan` succeeds).
        *   Downloads the `tfplan` artifact from the `terraform_plan` job.
        *   Performs `terraform init`.
        *   Executes `terraform apply -auto-approve tfplan` to provision or update resources.
*   **How to Use:**
    1.  **For changes:** Create a new branch, make your Terraform changes, commit, and push.
    2.  **Open a Pull Request:** Open a PR targeting `main`. The `terraform_plan` job will run, showing the proposed changes. Review the plan carefully.
    3.  **Merge to `main`:** Once the PR is approved and merged, the `terraform_apply` job will trigger. It will await manual approval (if configured) before executing `terraform apply`.

## 4. Application CI/CD Workflow (`doc-qa-bot-application-code`)

*   **Workflow File:** `application-code/.github/workflows/build_and_push.yml`
*   **Purpose:** Automates the building, testing, and pushing of Docker images for the Ingestor and Chat API services to Amazon ECR, including security scanning.
*   **Triggers:**
    *   `pull_request` merged to `main` branch.
*   **Jobs:**
    *   `build_and_push_images`:
        *   Runs on `pull_request` (before merge).
        *   **Sets up Python environment.**
        *   **Installs application and testing dependencies (including `flake8` and `pytest`).**
        *   **Runs code linters (`flake8`).**
        *   **Executes unit tests (`pytest`).**
        *   Logs into ECR.
        *   Builds Docker images for both `ingestor` and `chat-api` services.
        *   Tags images with `latest` and the Git SHA (`${{ github.sha }}`).
        *   Pushes both tagged images to their respective ECR repositories.
        *   **Scans built Docker images for vulnerabilities using Trivy.**
*   **How to Use:**
    1.  **For new features/bug fixes:** Create a new branch, write/modify application code, commit, and push.
    2.  **Open a Pull Request:** Open a PR targeting `main`. The workflow will run tests, linting, build, and push images for validation/testing purposes.
    3.  **Merge to `main`:** Once the PR is approved and merged, the workflow will build, test, scan, and push the final `latest` and SHA-tagged images to ECR, making them available for deployment.

## 5. Application Deployment Workflow (GitOps - `doc-qa-bot-kubernetes-helm-charts`)

*   **Primary Tool:** A GitOps operator (e.g., Argo CD, Flux CD) deployed within your EKS cluster.
*   **Workflow:** This is a pull-based deployment model, meaning the operator *pulls* changes from the Git repository, rather than GitHub Actions *pushing* deployments.
*   **Process:**
    1.  **Image Available:** A new Docker image (e.g., `ingestor:<NEW_SHA>`) is pushed to ECR by the `doc-qa-bot-application-code` CI pipeline.
    2.  **Helm Chart Update:** The `doc-qa-bot-kubernetes-helm-charts` repository contains Helm charts that define the desired state of your applications on Kubernetes. To deploy the new image, you would update the relevant `values.yaml` file (e.g., `helm/ingestor/values.yaml`) to reference the new image tag.
        *   This update can be done manually by a developer/DevOps engineer committing directly to `main`.
        *   **Automated (Recommended):** Tools like Renovate Bot or custom scripts can automatically open Pull Requests to update image tags in `values.yaml` files when new images are detected in ECR. Merging these PRs triggers the next step.
    3.  **GitOps Operator Reconciliation:** The GitOps operator continuously monitors the `doc-qa-bot-kubernetes-helm-charts` repository. Upon detecting a new commit (e.g., with an updated image tag in `values.yaml`):
        *   It fetches the latest Helm chart definitions.
        *   It applies these definitions to your EKS cluster.
        *   Kubernetes performs a rolling update (or other specified deployment strategy) to deploy the new version of your application with zero downtime.
*   **Benefits:** Ensures that your live cluster always matches the desired state in Git, provides high auditability, and enables fast, safe, and automated deployments.

## 6. Required GitHub Secrets

While OIDC reduces the need for long-lived AWS credentials, some secrets are still required:

*   **For `doc-qa-bot-application-code` and `doc-qa-bot-infrastructure-code` repositories:**
    *   `AWS_ACCOUNT_ID`: Your 12-digit AWS account ID. This is used in the `role-to-assume` ARN for OIDC authentication.

**Note:** Ensure all secrets are configured in your GitHub repository settings under `Settings > Secrets and variables > Actions > Repository secrets`. 