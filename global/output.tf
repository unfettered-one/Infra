
output "tfstate_bucket_name" {
  description = "Name of the S3 bucket storing Terraform state"
  value       = aws_s3_bucket.tfstate_bucket.bucket
}

output "tfstate_lock_table_name" {
  description = "DynamoDB table used for Terraform state locking"
  value       = aws_dynamodb_table.tfstate_locks.name
}

output "aws_account_id" {
  description = "AWS account ID where backend resources were created"
  value       = data.aws_caller_identity.current.account_id
}

output "stage" {
  description = "Deployment stage (dev, int, prod)"
  value       = var.stage
}

# Output: AWS region
output "region" {
  description = "AWS region used to deploy resources"
  value       = var.region
}
