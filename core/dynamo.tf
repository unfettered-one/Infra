
resource "aws_dynamodb_table" "service_table" {
  for_each = var.dynamodb_tables

  name         = each.key
  billing_mode = "PAY_PER_REQUEST" # free tier + scalable

  hash_key  = "pk"
  range_key = each.value.sort_key ? "sk" : null

  attribute {
    name = "pk"
    type = "S"
  }

  dynamic "attribute" {
    for_each = each.value.sort_key ? [1] : []
    content {
      name = "sk"
      type = "S"
    }
  }

  dynamic "attribute" {
    for_each = each.value.new_attribute != "" ? [1] : []
    content {
      name = each.value.new_attribute
      type = "S"
    }
  }

  dynamic "global_secondary_index" {
    for_each = each.value.gsi != "" && each.value.new_attribute != "" ? [1] : []
    content {
      name            = each.value.gsi
      hash_key        = each.value.new_attribute
      projection_type = "ALL"
    }
  }

  tags = {
    ManagedBy = "UnfetteredOne"
    Stage     = var.stage
    Service   = var.service_name
  }
}


output "dynamodb_table_names" {
  description = "Map of DynamoDB table names (key = table key, value = table name)"
  value       = { for k, v in aws_dynamodb_table.service_table : k => v.name }
}

output "dynamodb_table_arns" {
  description = "Map of DynamoDB table ARNs (key = table key, value = table ARN)"
  value       = { for k, v in aws_dynamodb_table.service_table : k => v.arn }
}
