#Provider configuration for AWS for terraform backend

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      ManagedBy   = "UnfetteredOne"
      Environment = var.stage
    }
  }
}
