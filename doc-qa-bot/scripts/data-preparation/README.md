# Data Preparation Scripts

This directory contains scripts for preparing and uploading documentation data for the Doc QA Bot.

## Scripts

### prepare_k8s_docs.py

Processes Kubernetes documentation by:
- Organizing documentation by categories
- Creating metadata for each document
- Preparing files for ingestion

Usage:
```bash
python prepare_k8s_docs.py
```

### upload_to_s3.py

Uploads processed documentation to S3 for ingestion by the Doc QA Bot.

Usage:
```bash
# Set environment variables
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_REGION=your_region
export S3_BUCKET_NAME=your-bucket-name

# Run the script
python upload_to_s3.py
```

## Directory Structure

```
data-preparation/
├── prepare_k8s_docs.py    # Script to process Kubernetes docs
├── upload_to_s3.py        # Script to upload docs to S3
└── README.md             # This file
```

## Dependencies

These scripts require:
- Python 3.8+
- boto3 (for S3 upload)
- AWS credentials configured

## Data Flow

1. Raw documentation is processed by `prepare_k8s_docs.py`
2. Processed files are uploaded to S3 using `upload_to_s3.py`
3. The Doc QA Bot ingests the files from S3 