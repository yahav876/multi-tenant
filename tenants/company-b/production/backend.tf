# Backend configuration for Company B - Production
# Configure remote state storage and locking

terraform {
  backend "gcs" {
    # Update these values based on your actual backend configuration
    bucket = "terraform-state-company-b-production"
    prefix = "company-b/production"
  }
}

# Alternative: S3 backend for AWS
# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-company-b-production"
#     key            = "company-b/production/terraform.tfstate"
#     region         = "us-west-2"
#     dynamodb_table = "terraform-locks-company-b"
#     encrypt        = true
#   }
# }

# Alternative: Local backend for testing (not recommended for production)
# terraform {
#   backend "local" {
#     path = "./terraform.tfstate"
#   }
# }
