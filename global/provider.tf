#Provider configuration for AWS for terraform backend

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      ManagedBy   = "UnfetteredOne"
      Environment = var.stage
    }
  }
}
