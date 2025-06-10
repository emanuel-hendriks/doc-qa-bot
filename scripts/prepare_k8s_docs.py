import os
import shutil
import json
from pathlib import Path

# Source and destination directories
K8S_DOCS_DIR = "data/k8s-docs/content/en/docs"
OUTPUT_DIR = "data/processed/k8s-docs"

# Categories to process
CATEGORIES = [
    "concepts",
    "tasks",
    "tutorials",
    "setup",
    "reference"
]

def create_metadata(file_path, category):
    """Create metadata for a documentation file"""
    relative_path = os.path.relpath(file_path, K8S_DOCS_DIR)
    return {
        "source": "kubernetes",
        "category": category,
        "path": relative_path,
        "format": "markdown"
    }

def process_docs():
    # Create output directory
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    # Process each category
    for category in CATEGORIES:
        category_dir = os.path.join(K8S_DOCS_DIR, category)
        if not os.path.exists(category_dir):
            continue
            
        # Create category directory in output
        output_category_dir = os.path.join(OUTPUT_DIR, category)
        os.makedirs(output_category_dir, exist_ok=True)
        
        # Walk through all markdown files
        for root, _, files in os.walk(category_dir):
            for file in files:
                if file.endswith('.md'):
                    src_path = os.path.join(root, file)
                    rel_path = os.path.relpath(src_path, category_dir)
                    dst_path = os.path.join(output_category_dir, rel_path)
                    
                    # Create destination directory if it doesn't exist
                    os.makedirs(os.path.dirname(dst_path), exist_ok=True)
                    
                    # Copy the file
                    shutil.copy2(src_path, dst_path)
                    
                    # Create and save metadata
                    metadata = create_metadata(src_path, category)
                    metadata_path = dst_path + '.json'
                    with open(metadata_path, 'w') as f:
                        json.dump(metadata, f, indent=2)

if __name__ == "__main__":
    process_docs()
    print("Documentation processing complete!") 