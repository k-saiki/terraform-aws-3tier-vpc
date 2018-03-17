# terraform-aws-3tier-vpc
Terraform module to create 3 tier subnets VPC on AWS.

## Usage
```hcl
provider aws {
  version = "1.11.0"
  region  = "ap-northeast-1"
}

module "vpc" {
  source = "github.com/k-saiki/terraoform-aws-vpc-3tier"

  providers = {
    aws = "aws"
  }

  name                 = "system-dev"
  cidr                 = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  azs               = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  public_subnets    = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  protected_subnets = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  private_subnets   = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway                = true
  single_nat_gateway                = false
  enable_dhcp_options               = false
  dhcp_options_domain_name          = "example.local"
  dhcp_options_domain_name_servers  = ["127.0.0.1", "10.0.0.2"]
  dhcp_options_ntp_servers          = []
  dhcp_options_netbios_name_servers = []
  dhcp_options_netbios_node_type    = ""

  tags = {
    Environment = "development"
    System      = "system"
  }
}
```