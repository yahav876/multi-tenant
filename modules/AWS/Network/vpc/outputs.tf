output "vpc_id" {
    value = module.vpc.vpc_id
    depends_on = [
      module.vpc
    ]
  }

output "azs_passed_to_module" {
  value = module.vpc.azs
}

output "subnets_id_public" {
     value = module.vpc.public_subnets
     depends_on = [
       module.vpc
     ]
 }

output "subnets_id_private" {
     value =  module.vpc.private_subnets
     depends_on = [
       module.vpc
     ]
 }

 output "vpc_cidr" {
   value = module.vpc.vpc_cidr_block
 }

