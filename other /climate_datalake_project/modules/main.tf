# # ---------------------------------------------------------------------------------------------------------------------
# # backend
# # ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = "~> 1"

  required_providers {
    aws = {
      version = "~> 5"
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {
    region = "eu-central-2"
    bucket = "jungfrau-climate-datalake-backend-bucket"
    key    = "jungfrau-hacakthon-climatedatalake.tfstate" 

    encrypt = true

    dynamodb_table = "climate-datalake-tfstate-locking"
  }
}

provider "aws" {
    region = "eu-central-2"
}

data "aws_caller_identity" "current" {
}
