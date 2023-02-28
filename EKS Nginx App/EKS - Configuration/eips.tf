//in this module we will be using the AWS elastic ip service and using these for our NAT gateway
//We are using NAT gateways for our private subnets to allow them to connect to the internet to recevie updates etc
//using the NAT gatway is egress only and so the outside internet will not be able to directly access the contents of the private subnets

resource "aws_eip" "nat1" {
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "nat2" {
  depends_on = [aws_internet_gateway.igw]
}