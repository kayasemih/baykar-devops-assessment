# ============================================================
# Terraform — ECR (Container Registry)
# ============================================================
# Where our Docker images live. Each component gets its own repo.
# ============================================================

resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}/frontend"
  image_tag_mutability = "IMMUTABLE" # Once a tag is pushed, it can't be overwritten. Safety first.

  image_scanning_configuration {
    scan_on_push = true # Automatically scan for vulnerabilities on push
  }

  tags = {
    Component = "frontend"
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}/backend"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Component = "backend"
  }
}

resource "aws_ecr_repository" "etl" {
  name                 = "${var.project_name}/etl"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Component = "etl"
  }
}

resource "aws_ecr_repository" "mongodb" {
  name                 = "${var.project_name}/mongodb"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Component = "mongodb"
  }
}

# --- Lifecycle Policy ---
# Keep only the last 10 images per repo to control storage costs.
# Old images are automatically cleaned up.
#
# NOTE: Defining these individually because the repos above aren't
# created with for_each — you can't dynamically reference them.
# A cleaner approach would be to define repos with for_each too,
# but explicit repos are more readable for a case study.

resource "aws_ecr_lifecycle_policy" "frontend_cleanup" {
  repository = aws_ecr_repository.frontend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "backend_cleanup" {
  repository = aws_ecr_repository.backend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "etl_cleanup" {
  repository = aws_ecr_repository.etl.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "mongodb_cleanup" {
  repository = aws_ecr_repository.mongodb.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
