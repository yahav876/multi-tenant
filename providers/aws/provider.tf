# AWS Provider Configuration
# This file contains AWS provider configuration and common settings

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  # Default tags applied to all AWS resources
  default_tags {
    tags = var.default_tags
  }
}

# Variables for AWS provider configuration
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "default_tags" {
  description = "Default tags to apply to all AWS resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
    Provider  = "aws"
  }
}

# Optional: Configure AWS CLI profile
# provider "aws" {
#   profile = var.aws_profile
#   region  = var.aws_region
# }

# Optional: Assume role configuration
# provider "aws" {
#   assume_role {
#     role_arn = var.aws_assume_role_arn
#   }
#   region = var.aws_region
# }
