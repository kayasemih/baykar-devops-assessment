locals {
  github_repository_value = var.github_repository == null ? "" : trimspace(var.github_repository)
  github_oidc_enabled     = local.github_repository_value != ""
  github_oidc_subject     = "repo:${local.github_repository_value}:ref:refs/heads/${var.github_oidc_branch}"
}

data "tls_certificate" "github_actions" {
  count = local.github_oidc_enabled ? 1 : 0
  url   = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  count = local.github_oidc_enabled ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.github_actions[0].certificates[*].sha1_fingerprint
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  count = local.github_oidc_enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.github_oidc_subject]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  count = local.github_oidc_enabled ? 1 : 0

  name               = "${var.project_name}-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role[0].json
}

data "aws_iam_policy_document" "github_actions_permissions" {
  count = local.github_oidc_enabled ? 1 : 0

  statement {
    sid    = "DescribeEksCluster"
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
    ]
    resources = [aws_eks_cluster.main.arn]
  }

  statement {
    sid    = "CreateProjectEcrRepositories"
    effect = "Allow"
    actions = [
      "ecr:CreateRepository",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "PushProjectImagesToEcr"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [
      aws_ecr_repository.frontend.arn,
      aws_ecr_repository.backend.arn,
      aws_ecr_repository.etl.arn,
      aws_ecr_repository.mongodb.arn,
    ]
  }

  statement {
    sid    = "GetEcrAuthToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_actions" {
  count = local.github_oidc_enabled ? 1 : 0

  name   = "${var.project_name}-github-actions-policy"
  role   = aws_iam_role.github_actions[0].id
  policy = data.aws_iam_policy_document.github_actions_permissions[0].json
}

resource "aws_eks_access_entry" "github_actions" {
  count = local.github_oidc_enabled ? 1 : 0

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_iam_role.github_actions[0].arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions_admin" {
  count = local.github_oidc_enabled ? 1 : 0

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_iam_role.github_actions[0].arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
