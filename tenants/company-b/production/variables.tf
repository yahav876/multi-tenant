# Company B - Production Environment Variables

variable "company" {
  description = "Company identifier"
  type        = string
  default     = "company-b"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "region" {
  description = "AWS/GCP region"
  type        = string
  default     = "us-central1"  # Different region for Company B
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "company-b-production"
}

# Add more variables as needed for your infrastructure
variable "instance_type" {
  description = "Instance type for compute resources"
  type        = string
  default     = "e2-standard-4"  # GCP instance type for production
}

variable "min_nodes" {
  description = "Minimum number of nodes in cluster"
  type        = number
  default     = 3
}

variable "max_nodes" {
  description = "Maximum number of nodes in cluster"
  type        = number
  default     = 10
}

# Common tags for all resources
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Company     = "company-b"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
