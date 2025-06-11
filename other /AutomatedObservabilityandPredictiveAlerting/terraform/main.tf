terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "terraform_state" {
  source = "./state"

  state_bucket_name = "automated-observability-terraform-state"
  environment       = "dev"
} 