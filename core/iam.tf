

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.service_name}-${var.stage}-lambda-role"

  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy.json

  tags = {
    ManagedBy = "UnfetteredOne"
    Stage     = var.stage
  }
}


# Attach Provided IAM Policy to Lambda Execution Role
resource "aws_iam_role_policy_attachment" "lambda_custom_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = var.lambda_execution_policy_arn

  lifecycle {
    precondition {
      condition     = length(var.lambda_execution_policy_arn) > 0
      error_message = "ERROR: lambda_execution_policy_arn is required. Please pass a valid IAM policy ARN."
    }
  }
}


resource "aws_iam_role_policy_attachment" "lambda_logs_basic" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


