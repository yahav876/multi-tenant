variable "create_app_of_apps" {
  type    = bool
  default = true
}

variable "argocd_namespace" {
  type = string
}

variable "app_of_apps_repo_url" {
  type = string
}

variable "app_of_apps_repo_revision" {
  type = string
}

variable "app_of_apps_path" {
  type = string
}

variable "app_of_apps_path_services" {
  type = string
}

variable "labels" {
  type    = map(string)
  default = {}
}
