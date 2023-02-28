// Creating out VPC and setting out configurations that are mandatory for eks cluster

resource "aws_vpc" "vpc-eks" {
  cidr_block = "10.0.0.0/16"

  //makes our instances shared on the host
  instance_tenancy = "default"
  //required for EKS
  enable_dns_support = true
  //required for EKS
  enable_dns_hostnames = true

  tags = {
    name = "vpc-eks"
  }
}

output "vpc_id" {
  value       = aws_vpc.vpc-eks.id
  description = "output our VPC id"
} 