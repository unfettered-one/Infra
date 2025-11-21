output "lambda_function_name" {
  value = (var.use_zip ?
    aws_lambda_function.zip_lambda[0].function_name :
  aws_lambda_function.container_lambda[0].function_name)
}

output "lambda_function_arn" {
  value = (var.use_zip ?
    aws_lambda_function.zip_lambda[0].arn :
  aws_lambda_function.container_lambda[0].arn)
}

output "lambda_invoke_arn" {
  value = (var.use_zip ?
    aws_lambda_function.zip_lambda[0].invoke_arn :
  aws_lambda_function.container_lambda[0].invoke_arn)
}

output "lambda_image_repository_url" {
  value = (var.use_container && var.use_ecr ?
    aws_ecr_repository.lambda_repo[0].repository_url :
  null)
}

# OUTPUT: Role ARN for Lambda
output "lambda_role_arn" {
  value = aws_iam_role.lambda_exec_role.arn
}
