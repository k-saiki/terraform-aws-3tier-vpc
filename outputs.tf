# VPC
output "vpc_id" {
  value = "${element(concat(aws_vpc.this.*.id, list("")), 0)}"
}

output "vpc_cidr_block" {
  value = "${element(concat(aws_vpc.this.*.cidr_block, list("")), 0)}"
}

output "vpc_instance_tenancy" {
  value = "${element(concat(aws_vpc.this.*.instance_tenancy, list("")), 0)}"
}

output "vpc_enable_dns_support" {
  value = "${element(concat(aws_vpc.this.*.enable_dns_support, list("")), 0)}"
}

output "vpc_enable_dns_hostnames" {
  value = "${element(concat(aws_vpc.this.*.enable_dns_hostnames, list("")), 0)}"
}

output "vpc_main_route_table_id" {
  value = "${element(concat(aws_vpc.this.*.main_route_table_id, list("")), 0)}"
}

# Subnets
output "public_subnets" {
  value = ["${aws_subnet.public.*.id}"]
}

output "public_subnets_cidr_blocks" {
  value = ["${aws_subnet.public.*.cidr_block}"]
}

output "protected_subnets" {
  value = ["${aws_subnet.protected.*.id}"]
}

output "protected_subnets_cidr_blocks" {
  value = ["${aws_subnet.protected.*.cidr_block}"]
}

output "private_subnets" {
  value = ["${aws_subnet.private.*.id}"]
}

output "private_subnets_cidr_blocks" {
  value = ["${aws_subnet.private.*.cidr_block}"]
}

# Route tables
output "public_route_table_ids" {
  value = ["${aws_route_table.public.*.id}"]
}

output "protected_route_table_ids" {
  value = ["${aws_route_table.protected.*.id}"]
}

output "private_route_table_ids" {
  value = ["${aws_route_table.private.*.id}"]
}

output "nat_eip_ids" {
  value = ["${aws_eip.nat.*.id}"]
}

output "nat_public_ips" {
  value = ["${aws_eip.nat.*.public_ip}"]
}

output "natgw_ids" {
  value = ["${aws_nat_gateway.this.*.id}"]
}

# Internet Gateway
output "igw_id" {
  value = "${element(concat(aws_internet_gateway.this.*.id, list("")), 0)}"
}
