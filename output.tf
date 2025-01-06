
## vpc1 ##
output "vpc1_id" {
  value = module.vpc1.vpc_id
}

output "vpc1_public_subnet_ids" {
  value = module.vpc1.public_subnets
}

output "vpc1_private_subnet_ids" {
  value = module.vpc1.private_subnets
}

## vpc1 ##
output "vpc2_id" {
  value = module.vpc2.vpc_id
}

output "vpc2_public_subnet_ids" {
  value = module.vpc2.public_subnets
}

output "vpc2_private_subnet_ids" {
  value = module.vpc2.private_subnets
}