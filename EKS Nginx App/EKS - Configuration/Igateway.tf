// Setting up our internet gateway and attaching this to our VPC 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-eks.id
}