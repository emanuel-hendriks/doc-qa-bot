# Data Sources & S3 Storage Strategy

To power the PoC RAG pipeline, you’ll need a handful of representative, publicly-available documents. Below is a breakdown of where to fetch them, how to organize them in your local workspace, and the best practices for uploading and storing them in your S3 “docs-raw” bucket.

---

## 1. Selecting and fetching public documents

Choose 5–10 documents covering a variety of formats (PDF, Markdown, HTML) and topics so you can demonstrate language-agnostic ingestion, chunking, and retrieval.

| Source type       | Example URLs or repos                                                                      | Format     | Fetch mechanism                  |
|-------------------|--------------------------------------------------------------------------------------------|------------|----------------------------------|
| **AWS whitepapers**   | https://aws.amazon.com/whitepapers/                                                       | PDF        | `wget` or `curl` to download     |
| **Kubernetes docs**   | https://github.com/kubernetes/website/tree/main/content/en/docs                           | Markdown   | `git clone` + `cp`               |
| **Linux man pages**   | https://www.kernel.org/doc/man-pages/                                                     | HTML       | `wget -r --accept html`          |
| **OpenAPI specs**     | https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/versions/3.0.3.md         | Markdown   | `curl -o`                        |
| **RFCs & standards**  | https://www.rfc-editor.org/rfc/rfcXXXX.txt                                                | TXT        | `wget https://…/rfcXXXX.txt`     |

### Example fetch commands

```bash
# Download a PDF
mkdir -p data/pdf
wget -qO data/pdf/aws-well-architected.pdf https://d1.awsstatic.com/whitepapers/architecture/AWS-Well-Architected-Framework.pdf

# Clone Markdown repo and copy files
git clone https://github.com/kubernetes/website.git data/k8s-docs
find data/k8s-docs/content/en/docs -name '*.md' -exec cp {} data/md/ \;

# Mirror HTML man-pages
mkdir -p data/html/man-pages
wget -q -r -l2 -P data/html/man-pages --accept html https://www.kernel.org/doc/man-pages/
```

---

## 2. Local staging area

Organize your local directory so the ingestor job can map folder names to S3 prefixes:

```
./data
├── pdf/               ← PDF whitepapers
├── md/                ← Markdown docs
└── html/              ← HTML pages & man-pages
```

Optionally, rename files to include a source prefix for easier metadata extraction later (e.g., `aws-waf-01-whitepaper.pdf`, `k8s-how-to-deploy.md`).

---

## 3. Uploading to S3

Use the AWS CLI or a simple Python/Boto3 script to mirror your `data/` directory into the S3 bucket. Leverage S3 versioning and object tagging for traceability.

1. **Enable versioning** on the bucket (in Terraform):

   ```hcl
   resource "aws_s3_bucket" "docs_raw" {
     bucket = "kb-demo-docs-raw"
     versioning {
       enabled = true
     }
     server_side_encryption_configuration { … }
   }
   ```

2. **Bulk upload** with AWS CLI:

   ```bash
   aws s3 sync ./data/ s3://kb-demo-docs-raw/raw/      --acl bucket-owner-full-control      --exclude "*"      --include "*.pdf" --include "*.md" --include "*.html"      --metadata-directive REPLACE      --metadata source="public"      --storage-class STANDARD
   ```

3. **Automate uploads** in CI/CD:

   ```yaml
   - name: Upload docs to S3
     run: aws s3 sync data/ s3://kb-demo-docs-raw/raw/ --exact-timestamps
   ```

---

## 4. S3 organization & lifecycle

Inside your bucket, maintain a clear prefix structure and lifecycle policies:

```
s3://kb-demo-docs-raw/
├── raw/                   ← Original inputs for ingestion
│   ├── pdf/
│   ├── md/
│   └── html/
├── processed/             ← (Optional) cleaned or reformatted files
└── archived/              ← (Optional) older versions via lifecycle rules
```

- **Lifecycle rule**: Move objects in `raw/` older than 30 days to `GLACIER`
- **Object tagging**: tag each file with `format=pdf|md|html`, `source=aws|k8s|linux`, and `version` (e.g., `v1.0`)

---

## 5. Ingestor expectations

Your Kubernetes `ingestor` CronJob will:

1. **List** new keys under `raw/` (e.g., via `boto3.list_objects_v2(Prefix='raw/')`)
2. **Download** each file to local `/tmp` for parsing
3. **Extract** text and metadata (file name, date, source tag)
4. **Emit** embeddings and upsert into pgvector

By keeping S3 storage structured and tagged, you simplify metadata-driven features later (e.g., filtering retrieval by document type or age) and set the stage for a robust, scalable RAG pipeline.
