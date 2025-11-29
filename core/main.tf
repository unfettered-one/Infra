
# Validation Locals
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Validation check resource - validates all conditions
resource "null_resource" "validate_inputs" {
  lifecycle {
    precondition {
      condition     = (var.use_zip ? 1 : 0) + (var.use_container ? 1 : 0) == 1
      error_message = "ERROR: Select exactly one deployment mode (use_zip OR use_container)."
    }

    precondition {
      condition = (
        var.use_container == false ||
        var.use_ecr == true ||
        (var.use_ecr == false && length(var.lambda_image_uri) > 0)
      )
      error_message = "ERROR: lambda_image_uri must be provided when use_container=true and use_ecr=false."
    }

    precondition {
      condition = (
        var.use_zip == false ||
        (var.use_zip == true && length(var.lambda_zip_path) > 0)
      )
      error_message = "ERROR: lambda_zip_path must be provided when use_zip=true."
    }

    precondition {
      condition     = length(var.lambda_execution_policy_arn) > 0
      error_message = "ERROR: lambda_execution_policy_arn must be provided."
    }
  }
}

