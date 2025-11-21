

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.service_name}-${var.stage}-lambda-role"

  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy.json

  tags = {
    ManagedBy = "UnfetteredOne"
    Stage     = var.stage
  }
}


#############################################
# VALIDATION - Ensure IAM Policy ARN Provided
#############################################

resource "null_resource" "policy_arn_validation" {
  triggers = {
    check = (length(var.lambda_execution_policy_arn) > 0 ?
      "ok" :
      throw("ERROR: lambda_execution_policy_arn is required. Please pass a valid IAM policy ARN.")
  ) }
}


# Attach Provided IAM Policy to Lambda Execution Role
resource "aws_iam_role_policy_attachment" "lambda_custom_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = var.lambda_execution_policy_arn
}


resource "aws_iam_role_policy_attachment" "lambda_logs_basic" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


