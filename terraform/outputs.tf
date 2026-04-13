# ============================================================
# Terraform — Outputs
# ============================================================
# After 'terraform apply', these values are printed.
# They're needed to configure kubectl and push images to ECR.
# ============================================================

output "cluster_name" {
  description = "EKS cluster name — use with: aws eks update-kubeconfig --name <value>"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS API endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "Kubernetes version running on the cluster"
  value       = aws_eks_cluster.main.version
}

output "ecr_frontend_url" {
  description = "ECR URL for frontend image"
  value       = aws_ecr_repository.frontend.repository_url
}

output "ecr_backend_url" {
  description = "ECR URL for backend image"
  value       = aws_ecr_repository.backend.repository_url
}

output "ecr_etl_url" {
  description = "ECR URL for ETL image"
  value       = aws_ecr_repository.etl.repository_url
}

output "ecr_mongodb_url" {
  description = "ECR URL for MongoDB image"
  value       = aws_ecr_repository.mongodb.repository_url
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "configure_kubectl" {
  description = "Command to configure kubectl for this cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC; set as the AWS_ROLE_ARN repository secret"
  value       = local.github_oidc_enabled ? aws_iam_role.github_actions[0].arn : null
}
