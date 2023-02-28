//In this module we will be associating the route tables with our subnets.
// we will create 2 for our public and 2 for private
resource "aws_route_table_association" "publicrouteassoc" {
  //subnet ID to attach routing table to
  subnet_id = aws_subnet.public_subnet1.id
  //route table ID
  route_table_id = aws_route_table.publicroute.id
}

resource "aws_route_table_association" "publicrouteassoc2" {
  //subnet ID to attach routing table to
  subnet_id = aws_subnet.public_subnet2.id
  //route table ID
  route_table_id = aws_route_table.publicroute.id
}

resource "aws_route_table_association" "privrouteassoc" {
  //subnet ID to attach routing table to
  subnet_id = aws_subnet.private_subnet1.id
  //route table ID
  route_table_id = aws_route_table.privateroute1.id
}

resource "aws_route_table_association" "privrouteassoc2" {
  //subnet ID to attach routing table to
  subnet_id = aws_subnet.private_subnet2.id
  //route table ID
  route_table_id = aws_route_table.privateroute2.id
}