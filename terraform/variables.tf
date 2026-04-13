# ============================================================
# Terraform — Variables
# ============================================================

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1" # Ireland — closest to Turkey with full EKS support
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "baykar-devops"
}

# --- VPC ---

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16" # 65,536 IP addresses — more than enough
}

# --- EKS ---

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.29"
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.medium" # 2 vCPU, 4GB RAM — good balance of cost and capacity
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the CI/CD role, in owner/repo format"
  type        = string
  default     = null
}

variable "github_oidc_branch" {
  description = "Git branch allowed to assume the CI/CD role"
  type        = string
  default     = "main"
}
