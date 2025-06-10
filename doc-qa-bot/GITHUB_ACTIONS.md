# GitHub Actions Workflows: CI/CD Guide

This document provides an overview of the GitHub Actions workflows implemented across the Doc QA Bot project repositories. For detailed information about each repository's CI/CD pipeline, please refer to the following documentation:

- [Application Code CI/CD Pipeline](../application-code/docs/CICD.md)
- [Infrastructure Code CI/CD Pipeline](../infrastructure-code/docs/CICD.md)
- [Kubernetes Helm Charts CI/CD Pipeline](../kubernetes-helm-charts/docs/CICD.md)

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

## 3. Infrastructure CI/CD Workflow

For detailed information about the infrastructure CI/CD workflow, including Terraform plan and apply processes, please refer to the [Infrastructure Code CI/CD Pipeline](../infrastructure-code/docs/CICD.md).

## 4. Application CI/CD Workflow

For detailed information about the application CI/CD workflow, including Docker image building and ECR push processes, please refer to the [Application Code CI/CD Pipeline](../application-code/docs/CICD.md).

## 5. Application Deployment Workflow (GitOps)

For detailed information about the GitOps deployment workflow, including Argo CD configuration and automated image updates, please refer to the [Kubernetes Helm Charts CI/CD Pipeline](../kubernetes-helm-charts/docs/CICD.md).

## 6. Required GitHub Secrets

While OIDC reduces the need for long-lived AWS credentials, some secrets are still required:

*   **For `doc-qa-bot-application-code` and `doc-qa-bot-infrastructure-code` repositories:**
    *   `AWS_ACCOUNT_ID`: Your 12-digit AWS account ID. This is used in the `role-to-assume` ARN for OIDC authentication.

**Note:** Ensure all secrets are configured in your GitHub repository settings under `Settings > Secrets and variables > Actions > Repository secrets`. 