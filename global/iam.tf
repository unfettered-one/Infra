
locals {
  deploy_role_name   = "terraform-deploy-role-${var.stage}"
  deploy_policy_name = "terraform-deploy-policy-${var.stage}"
}


# OIDC Provider for GitHub Actions
# (Created once per account; safe to reuse)
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    # GitHub Actions OIDC thumbprint
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}


# IAM Assume Role Policy for GitHub Actions

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {

    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.git_hub_user_name}/${var.repo_name}:ref:refs/heads/*"
      ]
    }
  }
}

# Create IAM Role for Terraform Deployments
resource "aws_iam_role" "terraform_deploy_role" {
  name               = local.deploy_role_name
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = {
    Name        = local.deploy_role_name
    Environment = var.stage
    ManagedBy   = "UnfetteredOne"
  }
}


# IAM Policy for Terraform Deploy Permissions
data "aws_iam_policy_document" "terraform_deploy_policy" {

  statement {
    effect = "Allow"
    actions = [
      "s3:*",
      "lambda:*",
      "apigateway:*",
      "dynamodb:*",
      "logs:*",
      "ssm:*",
      "iam:PassRole",
      "iam:GetRole",
      "iam:CreateRole",
      "iam:AttachRolePolicy"
    ]
    resources = ["*"]
  }
}


resource "aws_iam_role_policy" "terraform_deploy_role_policy" {
  name   = local.deploy_policy_name
  role   = aws_iam_role.terraform_deploy_role.id
  policy = data.aws_iam_policy_document.terraform_deploy_policy.json
}
