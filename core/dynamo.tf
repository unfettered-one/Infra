
resource "aws_dynamodb_table" "service_table" {
  count = var.enable_dynamodb ? 1 : 0

  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST" # free tier + scalable

  hash_key  = "pk"
  range_key = var.sort_key ? "sk" : null

  attribute {
    name = "pk"
    type = "S"
  }

  dynamic "attribute" {
    for_each = var.sort_key ? [1] : []
    content {
      name = "sk"
      type = "S"
    }
  }

  attribute {
    name = var.new_attribute
    type = "S"
  }

  global_secondary_index {
    name            = var.gsi
    hash_key        = var.new_attribute
    projection_type = "ALL"
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
