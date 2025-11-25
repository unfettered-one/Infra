
# Validation Locals
locals {
  # Exactly one mode must be enabled
  lambda_mode_error = (
    (var.use_zip ? 1 : 0) +
    (var.use_container ? 1 : 0)
  ) == 1 ? "" : "ERROR: Select exactly one deployment mode (use_zip OR use_container)."


  # External image requires image URI
  image_uri_error = (
    var.use_container == false ||
    var.use_ecr == true ||
    (var.use_ecr == false && length(var.lambda_image_uri) > 0)
  ) ? "" : "ERROR: lambda_image_uri must be provided when use_container=true and use_ecr=false."


  # Zip mode requires ZIP path
  zip_path_error = (
    var.use_zip == false ||
    (var.use_zip == true && length(var.lambda_zip_path) > 0)
  ) ? "" : "ERROR: lambda_zip_path must be provided when use_zip=true."


}

# Validation Resources to enforce checks
resource "null_resource" "lambda_mode_validation" {
  triggers = {
    check = local.lambda_mode_error != "" ? throw(local.lambda_mode_error) : "ok"
  }
}

resource "null_resource" "lambda_image_uri_validation" {
  triggers = {
    check = local.image_uri_error != "" ? throw(local.image_uri_error) : "ok"
  }
}

resource "null_resource" "lambda_zip_path_validation" {
  triggers = {
    check = local.zip_path_error != "" ? throw(local.zip_path_error) : "ok"
  }
}

resource "null_resource" "validate_lambda_policy" {
  triggers = {
    check = (length(var.lambda_execution_policy_arn) > 0 ?
      "ok" :
      throw("ERROR: lambda_execution_policy_arn must be provided.")
  ) }
}

