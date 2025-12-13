
# Locals for Lambda Naming & Logic
locals {
  lambda_name = "${var.service_name}-${var.stage}-${data.aws_caller_identity.current.account_id}-lambda"

  # If using ECR → construct image URI automatically
  final_image_uri = (var.use_ecr && var.use_container ?
    "${aws_ecr_repository.lambda_repo[0].repository_url}:latest" :
  var.lambda_image_uri)
}


resource "aws_cloudwatch_log_group" "lambda_log" {
  name              = "/aws/lambda/${local.lambda_name}"
  retention_in_days = 1

  tags = {
    ManagedBy = "UnfetteredOne"
    Stage     = var.stage
  }
}

# Optional ECR Repository for Image Mode
resource "aws_ecr_repository" "lambda_repo" {
  count = var.use_container && var.use_ecr ? 1 : 0

  name = "${var.service_name}-${var.stage}-${data.aws_caller_identity.current.account_id}"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    ManagedBy = "UnfetteredOne"
    Stage     = var.stage
  }
}


# Lambda ZIP Deployment (use_zip = true)

resource "aws_lambda_function" "zip_lambda" {
  count = var.use_zip ? 1 : 0

  function_name = local.lambda_name
  filename      = var.lambda_zip_path
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  role          = aws_iam_role.lambda_exec_role.arn

  timeout     = var.timeout
  memory_size = var.memory_size

  environment {
    variables = var.environment_variables
  }

  tags = {
    ManagedBy = "UnfetteredOne"
    Stage     = var.stage
  }
}



# Lambda Container Deployment (use_container = true)
resource "aws_lambda_function" "container_lambda" {
  count         = var.use_container ? 1 : 0
  function_name = local.lambda_name

  package_type = "Image"
  image_uri    = local.final_image_uri
  image_config {
    command = [var.lambda_handler]
  }

  role = aws_iam_role.lambda_exec_role.arn

  timeout     = var.timeout
  memory_size = var.memory_size

  environment {
    variables = var.environment_variables
  }

  tags = {
    ManagedBy = "UnfetteredOne"
    Stage     = var.stage
  }
}


# Lambda Function URL (only created when a Lambda is created)
resource "aws_lambda_function_url" "function_url" {
  count = (var.use_zip || var.use_container) ? 1 : 0

  function_name = var.use_zip ? aws_lambda_function.zip_lambda[0].function_name : aws_lambda_function.container_lambda[0].function_name

  # Publicly callable by default; change to "AWS_IAM" to require IAM auth
  authorization_type = "NONE"

  # Allow CORS from anywhere by default so the URL is reachable from browsers
  cors {
    allow_origins  = ["*"]
    allow_methods  = ["*"]
    allow_headers  = ["*"]
    expose_headers = ["*"]
    max_age        = 3600
  }
}



resource "aws_lambda_permission" "allow_public_url" {
  count                  = (var.use_zip || var.use_container) ? 1 : 0
  statement_id           = "AllowFunctionUrlInvoke"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = var.use_zip ? aws_lambda_function.zip_lambda[0].function_name : aws_lambda_function.container_lambda[0].function_name
  principal              = "*"
  function_url_auth_type = "NONE"
  depends_on = [
    aws_lambda_function_url.function_url
  ]
}

resource "aws_lambda_permission" "allow_public_invoke" {
  count         = (var.use_zip || var.use_container) ? 1 : 0
  statement_id  = "AllowPublicInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.use_zip ? aws_lambda_function.zip_lambda[0].function_name : aws_lambda_function.container_lambda[0].function_name
  principal     = "*"
}
