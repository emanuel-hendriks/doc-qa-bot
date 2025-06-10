# Doc QA Bot

A serverless knowledge bot that answers questions about documents with citations, powered by vector search and AWS Bedrock.

## Overview

This repository contains the application code for the Doc QA Bot. The infrastructure code is maintained in a separate repository: [doc-qa-bot-infrastructure](https://github.com/emanuel-hendriks/doc-qa-bot-infrastructure).

## Components

### 1. Ingestor Service (`src/ingestor/`)

A Python service that processes documents and prepares them for querying:

- **Features**:
  - Document processing (PDF, HTML, Markdown)
  - Text extraction and cleaning
  - Semantic chunking
  - Vector embedding generation
  - Database storage

- **Dependencies**:
  - FastAPI
  - PyPDF2
  - BeautifulSoup4
  - AWS SDK (boto3)
  - psycopg2-binary
  - pgvector

### 2. Chat API Service (`src/chat-api/`)

A Python service that handles user queries and generates responses:

- **Features**:
  - REST API and WebSocket endpoints
  - Vector similarity search
  - LLM integration with Bedrock
  - Citation generation
  - Response streaming

- **Dependencies**:
  - FastAPI
  - WebSockets
  - AWS SDK (boto3)
  - psycopg2-binary
  - pgvector

## Development

### Prerequisites

- Python 3.8+
- Docker
- AWS CLI configured
- Access to AWS Bedrock

### Local Development

1. **Set up virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # or `venv\Scripts\activate` on Windows
   pip install -r requirements.txt
   ```

2. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Run tests**
   ```bash
   pytest
   ```

4. **Build Docker images**
   ```bash
   docker build -t doc-qa-bot/ingestor:latest src/ingestor
   docker build -t doc-qa-bot/chat-api:latest src/chat-api
   ```

### API Documentation

#### Chat API Endpoints

1. **POST /chat**
   ```bash
   curl -X POST https://your-domain/chat \
     -H "Content-Type: application/json" \
     -H "x-api-key: your-api-key" \
     -d '{"question": "Your question here"}'
   ```

   Response:
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

2. **WebSocket /ws/chat**
   - Connects to streaming chat endpoint
   - Receives real-time updates

#### Ingestor API Endpoints

1. **POST /ingest**
   ```bash
   curl -X POST https://your-domain/ingest \
     -H "Content-Type: application/json" \
     -H "x-api-key: your-api-key" \
     -d '{"bucket": "your-bucket", "key": "document.pdf"}'
   ```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Testing

- Unit tests: `pytest tests/unit`
- Integration tests: `pytest tests/integration`
- End-to-end tests: `pytest tests/e2e`

## License

MIT License - see LICENSE file for details 