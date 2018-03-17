terraform {
  required_version = ">= 0.11.3"
}

locals {
  max_subnet_length = "${max(length(var.private_subnets), length(var.protected_subnets))}"
}

######
# VPC
######
resource "aws_vpc" "this" {
  cidr_block           = "${var.cidr}"
  instance_tenancy     = "${var.instance_tenancy}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"

  tags = "${merge(var.tags, map("Name", format("%s-vpc", var.name)))}"
}

###################
# DHCP Options Set
###################
resource "aws_vpc_dhcp_options" "this" {
  count = "${var.enable_dhcp_options ? 1 : 0}"

  domain_name          = "${var.dhcp_options_domain_name}"
  domain_name_servers  = ["${var.dhcp_options_domain_name_servers}"]
  ntp_servers          = ["${var.dhcp_options_ntp_servers}"]
  netbios_name_servers = ["${var.dhcp_options_netbios_name_servers}"]
  netbios_node_type    = "${var.dhcp_options_netbios_node_type}"

  tags = "${merge(var.tags, map("Name", format("%s-dhcp-options", var.name)))}"
}

###############################
# DHCP Options Set Association
###############################
resource "aws_vpc_dhcp_options_association" "this" {
  count = "${var.enable_dhcp_options ? 1 : 0}"

  vpc_id          = "${aws_vpc.this.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.this.id}"
}

###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(var.tags, map("Name", format("%s-igw", var.name)))}"
}

################
# Public routes
################
resource "aws_route_table" "public" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(var.tags, map("Name", format("%s-public", var.name)))}"
}

resource "aws_route" "public_internet_gateway" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"
}

#################
# Protected routes
#################
resource "aws_route_table" "protected" {
  count = "${local.max_subnet_length > 0 ? local.max_subnet_length : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(var.tags, map("Name", format("%s-protected-%s", var.name, element(split("-", element(var.azs, count.index)), 2))))}"
}

#################
# Private routes
#################
resource "aws_route_table" "private" {
  count = "${local.max_subnet_length > 0 ? local.max_subnet_length : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(var.tags, map("Name", format("%s-private-%s", var.name, element(split("-", element(var.azs, count.index)), 2))))}"
}

################
# Public subnet
################
resource "aws_subnet" "public" {
  count = "${length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"

  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${var.public_subnets[count.index]}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags = "${merge(var.tags, map("Name", format("%s-public-%s", var.name, element(split("-", element(var.azs, count.index)), 2))))}"
}

#################
# Protected subnet
#################
resource "aws_subnet" "protected" {
  count = "${length(var.protected_subnets) > 0 ? length(var.protected_subnets) : 0}"

  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${var.protected_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(var.tags, map("Name", format("%s-protected-%s", var.name, element(split("-", element(var.azs, count.index)), 2))))}"
}

#################
# Private subnet
#################
resource "aws_subnet" "private" {
  count = "${length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${var.private_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(var.tags, map("Name", format("%s-private-%s", var.name, element(split("-", element(var.azs, count.index)), 2))))}"
}

##############
# NAT Gateway
##############
locals {
  nat_gateway_ips = "${aws_eip.nat.*.id}"
}

resource "aws_eip" "nat" {
  count = "${var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0}"

  vpc = true

  tags = "${merge(var.tags, map("Name", format("%s-natgw-%s", var.name, element(split("-", element(var.azs, var.single_nat_gateway ? 0 : count.index)), 2))))}"
}

resource "aws_nat_gateway" "this" {
  count = "${var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0}"

  allocation_id = "${element(local.nat_gateway_ips, (var.single_nat_gateway ? 0 : count.index))}"
  subnet_id     = "${element(aws_subnet.public.*.id, (var.single_nat_gateway ? 0 : count.index))}"

  tags = "${merge(var.tags, map("Name", format("%s-natgw-%s", var.name, element(split("-", element(var.azs, var.single_nat_gateway ? 0 : count.index)), 2))))}"

  depends_on = ["aws_internet_gateway.this"]
}

resource "aws_route" "protected_nat_gateway" {
  count = "${var.enable_nat_gateway ? length(var.protected_subnets) : 0}"

  route_table_id         = "${element(aws_route_table.protected.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.this.*.id, count.index)}"
}

resource "aws_route" "private_nat_gateway" {
  count = "${var.enable_nat_gateway ? length(var.private_subnets) : 0}"

  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.this.*.id, count.index)}"
}

##########################
# Route table association
##########################
resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "protected" {
  count = "${length(var.protected_subnets) > 0 ? length(var.protected_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.protected.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.protected.*.id, count.index)}"
}

resource "aws_route_table_association" "private" {
  count = "${length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
