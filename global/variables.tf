variable "stage" {
  default     = "dev"
  description = "The environment stage (e.g., dev, prod)"
  type        = string
}


variable "aws_region" {
  default     = "ap-south-1" #(mumbai)
  description = "The AWS region to deploy resources"
  type        = string
}

variable "git_hub_user_name" {
  description = "GitHub username for repository access"
  type        = string

}
