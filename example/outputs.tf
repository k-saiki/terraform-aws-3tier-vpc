# VPC
output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

# Subnets
output "private_subnets" {
  value = ["${module.vpc.private_subnets}"]
}

output "protected_subnets" {
  value = ["${module.vpc.protected_subnets}"]
}

output "public_subnets" {
  value = ["${module.vpc.public_subnets}"]
}

# Route Tables
output "public_route_tables" {
  value = ["${module.vpc.public_route_table_ids}"]
}

output "protected_route_tables" {
  value = ["${module.vpc.protected_route_table_ids}"]
}

output "private_route_tables" {
  value = ["${module.vpc.private_route_table_ids}"]
}

# Internet gateways
output "internet_gateway" {
  value = ["${module.vpc.igw_id}"]
}

# NAT gateways
output "nat_public_ips" {
  value = ["${module.vpc.nat_public_ips}"]
}

output "nat_eip_ids" {
  value = ["${module.vpc.nat_eip_ids}"]
}

output "natgw_ids" {
  value = ["${module.vpc.natgw_ids}"]
}
