# ============================================================
# Terraform — Main Configuration
# ============================================================
# This sets up the AWS provider and remote Terraform backend.
# Backend details are supplied at init time via backend.hcl.
# ============================================================

terraform {
  required_version = ">= 1.5.0"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "baykar-devops-case"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Data source: get available AZs in the selected region
data "aws_availability_zones" "available" {
  state = "available"
}
