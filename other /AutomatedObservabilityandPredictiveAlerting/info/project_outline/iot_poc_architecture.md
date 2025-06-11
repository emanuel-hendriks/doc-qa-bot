
# IoT Sensor Data Analytics – DevOps PoC  
**Version:** 1.0 – 2025‑06‑09  

---

## Table of Contents
1. [Project Overview](#project-overview)  
2. [Context Diagram](#context-diagram)  
3. [Logical Architecture](#logical-architecture)  
4. [Component Descriptions](#component-descriptions)  
5. [Deployment Architecture (AWS)](#deployment-architecture-aws)  
6. [Data Flow](#data-flow)  
7. [Observability & SRE Stack](#observability--sre-stack)  
8. [Security & Compliance](#security--compliance)  
9. [CI/CD & IaC Workflow](#cicd--iac-workflow)  
10. [Non‑Functional Requirements](#non-functional-requirements)  
11. [Future Enhancements](#future-enhancements)  

---

## Project Overview
Real‑time analytics platform that ingests IoT sensor events, persists them in PostgreSQL, serves them through an API, and visualises them in a React dashboard.  
The PoC demonstrates:

* Infrastructure‑as‑Code with Terraform  
* Git‑based CI/CD using GitHub Actions  
* Kubernetes (EKS) deployments with auto‑scaling  
* End‑to‑end observability (metrics, logs, traces)  
* Basic anomaly detection and alerting  

---

## Context Diagram
```text
┌──────────────┐         ┌─────────────┐
│ IoT Devices  ├─HTTP──▶ │  Kinesis    │
└──────────────┘         └────┬────────┘
                              │
                     (1) Stream events
                              │
                              ▼
        ┌──────────────────────────────┐
        │   Ingestor (worker pods)     │
        └────────┬──────────┬──────────┘
                 │          │
        (2) write to   (3) custom metrics
                 │          │
                 ▼          ▼
        ┌──────────────────────────┐
        │   PostgreSQL (RDS)       │
        └────────┬─────────────────┘
                 │
        (4) REST queries
                 │
                 ▼
        ┌──────────────────────────┐
        │   FastAPI Service        │
        └────────┬─────────────────┘
                 │
          (5) JSON/HTTPS
                 │
                 ▼
        ┌──────────────────────────┐
        │  React Dashboard (SPA)   │
        └──────────────────────────┘
```

---

## Logical Architecture
| Layer | Services / Tools | Notes |
|-------|------------------|-------|
| **Ingestion** | AWS Kinesis Data Streams, `ingestor/` worker (Python) | Buffers bursty device traffic, decouples producers/consumers |
| **Processing & API** | FastAPI (Python), uvicorn | Serves CRUD for devices & readings |
| **Persistence** | PostgreSQL 15 on AWS RDS (single‑AZ) | Time‑series partitioning by month |
| **Analytics Jobs** | `anomaly-detector/` CronJob (statsmodels) | Runs every 5 min, writes alerts table & Prometheus metric |
| **Frontend** | React 18 + Vite, ECharts | Auth‑free SPA for PoC |
| **Observability** | Prometheus + Grafana, OpenTelemetry Collector, Grafana Tempo (optional), Loki (logs) | Deployed via kube‑prometheus‑stack Helm chart |
| **CI/CD** | GitHub Actions, Terraform Cloud (remote state) | OIDC auth to AWS |

---

## Component Descriptions
### 1. Ingestor
* Language: Python 3.12 (asyncio + boto3)  
* Reads batches from Kinesis shard iterator, validates JSON schema, inserts into `sensor_readings` table using `asyncpg` pool.  
* Publishes custom Prometheus metrics (`ingestor_batch_lag_seconds`, `ingestor_records_total`).  

### 2. FastAPI Service
* Endpoints  
  * `GET /health` – liveness  
  * `POST /readings` – bulk insert (internal)  
  * `GET /devices/{id}` – device info  
  * `GET /readings?device_id=&since=` – paginated query  
* Depends on RDS via IAM database authentication (no static passwords).

### 3. Anomaly‑Detector
* Kubernetes `CronJob` scheduled every 5 minutes.  
* Pulls last 15 min of CPU & latency metrics from Prometheus HTTP API, computes z‑score.  
* Emits `predictive_alert` metric and writes alert row into `alerts` table if score > 3.  

### 4. Frontend Dashboard
* WebSocket to FastAPI for live readings (optional fallback: HTTP polling).  
* Three panels: **Live Gauges**, **24 h Trend**, **Active Alerts**.  

---

## Deployment Architecture (AWS)
| Resource | Notes |
|----------|-------|
| **VPC** | 2 public + 2 private subnets, 1 NAT GW |
| **EKS** | `t3.medium` nodes × 2 (dev) with Cluster Autoscaler |
| **RDS** | db.t4g.small PostgreSQL, single‑AZ, 20 GiB gp2 |
| **Kinesis** | 1 shard (on‑demand), 24 h retention |
| **S3** | Private bucket for Terraform state (if not using TFC) |
| **IAM** | OIDC trust for GitHub, fine‑grained service roles |
| **ALB** | Ingress for `/api/*` and `/` (dashboard) |

---

## Data Flow
1. **Devices → Kinesis** – secure HTTPS PUT w/ presigned URL.  
2. **Ingestor → RDS** – batch writes every 2 s.  
3. **FastAPI → Dashboard** – REST & WS responses < 200 ms p99.  
4. **Prometheus Scrape** – every 15 s; stores 15 d of metrics.  
5. **Anomaly Detector → Alertmanager** – fires Slack webhook if z‑score triggers.  

---

## Observability & SRE Stack
* **Prometheus Operator** – auto‑discovers `ServiceMonitor` objects.  
* **Grafana Dashboards**  
  * _System Overview_ – node CPU, memory, disk, pod restarts.  
  * _API Performance_ – requests/sec, latency histogram, 5xx rate.  
  * _Ingestor Lag_ – Kinesis → DB lag seconds.  
* **Alerting Rules**  
  * `api_latency_p95 > 400ms for 2m` → warn  
  * `ingestor_batch_lag_seconds > 15` → critical  
  * `predictive_alert == 1` → critical  

---

## Security & Compliance
* IAM least‑privilege roles, scoped KMS keys.  
* Network: SG only allows 443/5432 from cluster‐CIDR.  
* Secrets: K8s `ExternalSecrets` + AWS Secrets Manager.  
* Image scan: Trivy in CI; fails PR on high CVEs.  

---

## CI/CD & IaC Workflow
1. **Pre‑merge** (`pull_request`):  
   * `terraform fmt && validate`  
   * `tflint` + `tfsec`  
   * `docker build --target test && pytest`  
2. **Merge to main**:  
   * `terraform plan -out=plan` → manual `apply` (dev)  
   * Build/push images → ECR w/ `semver` tag  
   * Helm upgrade via `helmfile apply`  
3. **Promotion to prod**: GitHub Release triggers prod workspace apply.

---

## Non‑Functional Requirements
| Category | Target |
|----------|--------|
| Availability | ≥ 99.9 % |
| API p99 latency | < 200 ms |
| Ingestion lag | < 5 s under 2 k eps |
| Cost cap (dev) | €5 / week |

---

## Future Enhancements
* Multi‑AZ RDS + replicas  
* Replace z‑score with Prophet model on SageMaker  
* Spark/Flink pipeline for long‑term analytics  
* Istio service mesh for mTLS & traffic splitting  
* Blue‑green or canary deploy via Argo Rollouts  

---

*Authored by Emanuel Hendriks – 2025‑06‑09*
