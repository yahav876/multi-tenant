module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 11.1"

  project_id   = var.gcp_project_id
  network_name = var.vpc_network_name
  routing_mode = var.vpc_routing_mode

  subnets = [
    {
      subnet_name           = var.vpc_subnet_name
      subnet_ip             = var.subnet_cidr
      subnet_region         = var.gcp_region
      subnet_private_access = var.vpc_subnet_private_access
      subnet_flow_logs      = var.vpc_subnet_flow_logs
      description           = var.vpc_subnet_description
    },
  ]

  secondary_ranges = {
    "${var.vpc_subnet_name}" = [
      {
        range_name    = var.vpc_pods_range_name
        ip_cidr_range = var.pods_cidr
      },
      {
        range_name    = var.vpc_services_range_name
        ip_cidr_range = var.services_cidr
      },
    ]
  }

  ingress_rules = var.vpc_ingress_rules

}
