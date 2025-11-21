
resource "aws_dynamodb_table" "service_table" {
  count = var.enable_dynamodb ? 1 : 0

  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST" # free tier + scalable

  hash_key = "pk"

  attribute {
    name = "pk"
    type = "S"
  }

  tags = {
    ManagedBy = "UnfetteredOne"
    Stage     = var.stage
    Service   = var.service_name
  }
}


output "dynamodb_table_name" {
  value = var.enable_dynamodb ? aws_dynamodb_table.service_table[0].name : null
}

output "dynamodb_table_arn" {
  value = var.enable_dynamodb ? aws_dynamodb_table.service_table[0].arn : null
}
