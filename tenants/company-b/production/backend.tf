# Backend configuration for Company B - Production
# Configure remote state storage and locking

# S3 backend for AWS
terraform {
  backend "s3" {
    bucket         = "terraform-yahav"
    key            = "company-b/production/terraform.tfstate"
    region         = "us-east-1"
    # dynamodb_table = "terraform-locks-company-b"
    # encrypt        = true
  }
}
