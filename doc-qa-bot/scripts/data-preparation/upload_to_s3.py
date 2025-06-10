import os
import boto3
import json
from pathlib import Path

def upload_to_s3(bucket_name, source_dir):
    """Upload processed documentation to S3 bucket"""
    s3_client = boto3.client('s3')
    
    # Walk through the source directory
    for root, _, files in os.walk(source_dir):
        for file in files:
            # Get the full path of the file
            file_path = os.path.join(root, file)
            
            # Calculate the S3 key (path in the bucket)
            # Remove the source_dir prefix from the path
            s3_key = os.path.relpath(file_path, source_dir)
            
            # Upload the file
            print(f"Uploading {file_path} to s3://{bucket_name}/{s3_key}")
            s3_client.upload_file(
                file_path,
                bucket_name,
                s3_key,
                ExtraArgs={
                    'ContentType': 'application/json' if file.endswith('.json') else 'text/markdown'
                }
            )

def main():
    # Get bucket name from environment variable or use default
    bucket_name = os.getenv('S3_BUCKET_NAME', 'syllotip-demo-docs')
    
    # Source directory containing processed documentation
    source_dir = 'data/processed/k8s-docs-processed'
    
    if not os.path.exists(source_dir):
        print(f"Error: Source directory {source_dir} does not exist")
        return
    
    try:
        upload_to_s3(bucket_name, source_dir)
        print("Upload completed successfully!")
    except Exception as e:
        print(f"Error uploading files: {str(e)}")

if __name__ == "__main__":
    main() 