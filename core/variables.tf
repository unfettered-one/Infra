
# Core Deployment Variables
variable "service_name" {
  description = "Name of the microservice (e.g., auth-service)"
  type        = string
}

variable "stage" {
  description = "Deployment environment (dev, stage, prod)"
  type        = string
}


# Deployment Mode Selection
variable "use_zip" {
  description = "Deploy Lambda using ZIP file"
  type        = bool
  default     = false
}

variable "use_container" {
  description = "Deploy Lambda using Docker image"
  type        = bool
  default     = true
}

variable "use_ecr" {
  description = "If true: use ECR image. If false: use external image URI."
  type        = bool
  default     = false
}



variable "lambda_zip_path" {
  description = "Path to ZIP file (required when use_zip = true)"
  type        = string
  default     = ""
}

variable "lambda_runtime" {
  description = "Lambda runtime when deploying ZIP"
  type        = string
  default     = "python3.12"
}

variable "lambda_handler" {
  description = "Lambda handler entrypoint (required when use_zip = true or use_container = true)"
  type        = string
  default     = ""
}


# Container Deployment Variables
variable "lambda_image_uri" {
  description = "Docker Image URI (required when use_container = true and use_ecr = false)"
  type        = string
  default     = ""
}


# Lambda Settings
variable "memory_size" {
  description = "Lambda memory size (MB)"
  type        = number
  default     = 512
}

variable "timeout" {
  description = "Lambda timeout (seconds)"
  type        = number
  default     = 30
}

variable "environment_variables" {
  description = "Environment variables for Lambda"
  type        = map(string)
  default     = {}
}



# Optional DynamoDB Table
variable "enable_dynamodb" {
  description = "Enable creation of a DynamoDB table"
  type        = bool
  default     = false
}

variable "dynamodb_table_name" {
  description = "Name of DynamoDB table (required if enabled)"
  type        = string
  default     = ""
}

variable "gsi" {
  description = "name of global secodary index"
  type        = string
  default     = ""
}

variable "new_attribute" {
  description = "New attribute for DynamoDB table"
  type        = string
  default     = ""
}


# IAM Role & Policies
variable "lambda_execution_policy_arn" {
  description = "IAM policy ARN to attach to Lambda execution role"
  type        = string
  default     = ""
}

variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
}

# --- API Gateway (HTTP API) ---

variable "create_http_api" {
  description = "Whether to create an API Gateway HTTP API from an OpenAPI spec"
  type        = bool
  default     = true
}

variable "api_spec_path" {
  description = "Path to the OpenAPI/Swagger spec file used to create the HTTP API"
  type        = string
  default     = ""
}
