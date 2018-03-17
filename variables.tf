variable "name" {
  type    = "string"
  default = ""
}

variable "cidr" {
  type    = "string"
  default = "0.0.0.0/0"
}

variable "instance_tenancy" {
  type    = "string"
  default = "default"
}

variable "public_subnets" {
  type    = "list"
  default = []
}

variable "protected_subnets" {
  type    = "list"
  default = []
}

variable "private_subnets" {
  type    = "list"
  default = []
}

variable "azs" {
  type    = "list"
  default = []
}

variable "enable_dns_hostnames" {
  default = true
}

variable "enable_dns_support" {
  default = true
}

variable "enable_nat_gateway" {
  default = false
}

variable "single_nat_gateway" {
  default = false
}

variable "map_public_ip_on_launch" {
  default = true
}

variable "tags" {
  type    = "map"
  default = {}
}

variable "enable_dhcp_options" {
  default = false
}

variable "dhcp_options_domain_name" {
  type    = "string"
  default = ""
}

variable "dhcp_options_domain_name_servers" {
  type    = "list"
  default = ["AmazonProvidedDNS"]
}

variable "dhcp_options_ntp_servers" {
  type    = "list"
  default = []
}

variable "dhcp_options_netbios_name_servers" {
  type    = "list"
  default = []
}

variable "dhcp_options_netbios_node_type" {
  type    = "string"
  default = ""
}
