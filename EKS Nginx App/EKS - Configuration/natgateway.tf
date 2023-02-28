//NAT gateway will work in a way that will translate the private address into a public address to access the internet
//This is placed inside the public subnet

resource "aws_nat_gateway" "natpriv1" {
  //allocation id of the Elastic IP address for the gateway
  allocation_id = aws_eip.nat1.id
  //the subnet ID of the subnet in which to place the gateway
  subnet_id = aws_subnet.public_subnet1.id

  //tags
  tags = {
    name = "NAT Gateway 1"
  }
}

resource "aws_nat_gateway" "natpriv2" {
  //allocation id of the Elastic IP address for the gateway
  allocation_id = aws_eip.nat2.id
  //the subnet ID of the subnet in which to place the gateway
  subnet_id = aws_subnet.public_subnet2.id

  //tags
  tags = {
    name = "NAT Gateway 2"
  }
}