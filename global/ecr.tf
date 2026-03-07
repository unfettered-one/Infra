# ECR Private Repository for storing container images
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

# Lifecycle policy to keep only recent images
resource "aws_ecr_lifecycle_policy" "lambda_images_lifecycle" {
  repository = aws_ecr_repository.lambda_images.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
