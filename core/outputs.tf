output "lambda_function_name" {
  value = (var.use_zip ?
    try(aws_lambda_function.zip_lambda[0].function_name, null) :
  try(aws_lambda_function.container_lambda[0].function_name, null))
}

output "lambda_function_arn" {
  value = (var.use_zip ?
    try(aws_lambda_function.zip_lambda[0].arn, null) :
  try(aws_lambda_function.container_lambda[0].arn, null))
}

output "lambda_invoke_arn" {
  value = (var.use_zip ?
    try(aws_lambda_function.zip_lambda[0].invoke_arn, null) :
  try(aws_lambda_function.container_lambda[0].invoke_arn, null))
}

output "lambda_image_repository_url" {
  value = ((var.use_container && var.use_ecr) ?
    try(aws_ecr_repository.lambda_repo[0].repository_url, null) :
  null)
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_exec_role.arn
}
