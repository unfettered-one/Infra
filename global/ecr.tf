# ECR Repository for storing container images
resource "aws_ecr_repository" "lambda_images" {
  name                 = "lambda-images"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    ManagedBy = "UnfetteredOne"
    Purpose   = "Lambda container images"
  }
}

# Make the repository publicly accessible
resource "aws_ecr_repository_policy" "lambda_images_public" {
  repository = aws_ecr_repository.lambda_images.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPublicPull"
        Effect = "Allow"
        Principal = "*"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages"
        ]
      }
    ]
  })
}

# Lifecycle policy to keep only recent images
resource "aws_ecr_lifecycle_policy" "lambda_images_lifecycle" {
  repository = aws_ecr_repository.lambda_images.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
