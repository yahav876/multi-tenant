variable "vpc_name" {
  type = string
}
variable "vpc_cidr" {
  type = string
}
variable "region" {
  type = string
}
variable "vpc_azs" {
  type = list(string)
}
variable "private_subnet_cidr" {
  type = list(string)
}
variable "public_subnet_cidr" {
  type = list(string)
}
variable "enable_nat_gateway" {
  type = bool
}
variable "one_nat_gateway_per_az" {
  type = bool
}

variable "private_subnet_tags" {
  description = "Additional tags to apply to private subnets"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags to apply to public subnets"
  type        = map(string)
  default     = {}
}


variable "subnets_id" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type    = string
  default = ""
}
