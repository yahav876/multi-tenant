# Backend configuration for Company A - Production Environment
# Store Terraform state in Google Cloud Storage for collaboration and state locking

terraform {
  backend "gcs" {
    bucket = "terraform-state-company-a-production"  # Replace with your actual GCS bucket name
    prefix = "company-a/production"
    
    # Optional: Enable state locking with Firestore
    # Requires Firestore database in the same project
    # Uncomment the line below if you have Firestore enabled:
    # encryption_key = "your-kms-key-id"  # Optional: Use KMS for encryption
  }
}

# Notes:
# 1. Create the GCS bucket before running terraform init:
#    gsutil mb gs://terraform-state-company-a-production
#    gsutil versioning set on gs://terraform-state-company-a-production
#
# 2. For state locking, enable Firestore API:
#    gcloud services enable firestore.googleapis.com
#    gcloud firestore databases create --region=us-central1
#
# 3. For encryption, create a KMS key:
#    gcloud kms keyrings create terraform --location=global
#    gcloud kms keys create terraform-state --location=global --keyring=terraform --purpose=encryption
