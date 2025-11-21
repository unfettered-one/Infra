# API Gateway HTTP API (not rest api) from OpenAPI spec
locals {
  http_api_name = "${var.service_name}-${var.stage}-http-api"
}



# HTTP API created directly from OpenAPI/Swagger spec
resource "aws_apigatewayv2_api" "http_api" {
  count = var.create_http_api ? 1 : 0

  name          = local.http_api_name
  protocol_type = "HTTP"

  # OpenAPI/Swagger document – JSON or YAML is fine
  body = file(var.api_spec_path)

  tags = {
    ManagedBy = "UnfetteredOne"
    Stage     = var.stage
    Service   = var.service_name
  }
}

# Default stage so the API is actually callable
resource "aws_apigatewayv2_stage" "default" {
  count = var.create_http_api ? 1 : 0

  api_id      = aws_apigatewayv2_api.http_api[0].id
  name        = "$default"
  auto_deploy = true

  tags = {
    ManagedBy = "UnfetteredOne"
    Stage     = var.stage
    Service   = var.service_name
  }
}


resource "aws_lambda_permission" "apigw_lambda" {
  count = var.create_http_api ? 1 : 0

  statement_id = "AllowAPIGatewayInvoke"
  action       = "lambda:InvokeFunction"
  function_name = (var.use_zip ?
    aws_lambda_function.zip_lambda[0].function_name :
    aws_lambda_function.container_lambda[0].function_name
  )
  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.http_api[0].execution_arn}/*/*"
}
