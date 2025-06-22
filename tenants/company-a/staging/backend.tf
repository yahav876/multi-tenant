# Backend configuration for Company A - Staging
# Configure remote state storage and locking

terraform {
  backend "s3" {
    # Update these values based on your actual backend configuration
    bucket         = "terraform-state-company-a-staging"
    key            = "company-a/staging/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks-company-a"
    encrypt        = true
    
    # Optional: Use workspace prefixes for better organization
    # workspace_key_prefix = "env:"
  }
}

# Alternative: GCS backend for Google Cloud
# terraform {
#   backend "gcs" {
#     bucket = "terraform-state-company-a-staging"
#     prefix = "company-a/staging"
#   }
# }

# Alternative: Local backend for testing (not recommended for production)
# terraform {
#   backend "local" {
#     path = "./terraform.tfstate"
#   }
# }
