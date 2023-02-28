//In this Module we will go ahead and great 1 public route table to route traffic to our internet gateway and accepting all IPs. 
//we will also create 2 private route tables for our NAT gateways to route traffic to these availability zones

resource "aws_route_table" "publicroute" {

  //VPC ID
  vpc_id = aws_vpc.vpc-eks.id

  route {
    //CIDR block of the route
    cidr_block = "0.0.0.0/0"
    //identifier of our Internet Gateway
    gateway_id = aws_internet_gateway.igw.id
  }
  //tags
  tags = {
    name = "publicroute"
  }
}

resource "aws_route_table" "privateroute1" {
  //VPC ID
  vpc_id = aws_vpc.vpc-eks.id

  route {
    //CIDR block of the route
    cidr_block = "0.0.0.0/0"
    //identifier of the NAT gateway
    nat_gateway_id = aws_nat_gateway.natpriv1.id
  }
  tags = {
    name = "privateroute1"
  }
}

resource "aws_route_table" "privateroute2" {
  //VPC ID
  vpc_id = aws_vpc.vpc-eks.id

  route {
    //CIDR block of the route
    cidr_block = "0.0.0.0/0"
    //identifier of the NAT gateway
    nat_gateway_id = aws_nat_gateway.natpriv2.id
  }
  tags = {
    name = "privateroute2"
  }
}