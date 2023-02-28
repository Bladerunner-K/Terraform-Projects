//in this module we will be setting up 2 public and private subnets in 2 different availablilty zones
// we will also tag our subnets so we can later attach these to the EKS cluster, internal load balancers and external load balancers
// after connecting into the cluster, using kubectl we will create services that will act as load balancers and attach themselves to the subnets by setting out annotations in the Yaml file


resource "aws_subnet" "public_subnet1" {
  //reference our vpc 
  vpc_id = aws_vpc.vpc-eks.id
  //set the CIDR block of the subnet
  cidr_block = "10.0.1.0/24"
  //availability zone
  availability_zone = "eu-west-2a"
  //required for EKS, intances launched inside the subnet will be automatically assigned an ip address 
  map_public_ip_on_launch = true


  //IMPORTANT TAGS - this is for the EKS cluster to be able to locate this subnet and also be able to attach a load balancer to it 
  tags = {
    name                        = "public-eu-west-2a"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}


resource "aws_subnet" "public_subnet2" {
  //reference our vpc 
  vpc_id = aws_vpc.vpc-eks.id
  //set the CIDR block of the subnet
  cidr_block = "10.0.2.0/24"
  //availability zone
  availability_zone = "eu-west-2b"
  //required for EKS, intances launched inside the subnet will be automatically assigned an ip address 
  map_public_ip_on_launch = true


  //IMPORTANT TAGS - this is for the EKS cluster to be able to locate this subnet and also be able to attach a load balancer to it 
  tags = {
    name                        = "public-eu-west-2b"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}



//setting up the private subnets -----------------------------------------------------------------------------
resource "aws_subnet" "private_subnet1" {
  //reference our vpc 
  vpc_id = aws_vpc.vpc-eks.id
  //set the CIDR block of the subnet
  cidr_block = "10.0.3.0/24"
  //availability zone
  availability_zone = "eu-west-2a"
  //required for EKS, intances launched inside the private subnet will not be automatically assigned an ip address 
  map_public_ip_on_launch = false


  //IMPORTANT TAGS - this is for the EKS cluster to be able to locate this subnet and also be able to attach a private load balancer to it 
  tags = {
    name                              = "private-eu-west-2a"
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "private_subnet2" {
  //reference our vpc 
  vpc_id = aws_vpc.vpc-eks.id
  //set the CIDR block of the subnet
  cidr_block = "10.0.4.0/24"
  //availability zone
  availability_zone = "eu-west-2b"
  //required for EKS, intances launched inside the private subnet will not be automatically assigned an ip address 
  map_public_ip_on_launch = false


  //IMPORTANT TAGS - this is for the EKS cluster to be able to locate this subnet and also be able to attach a private load balancer to it 
  tags = {
    name                              = "private-eu-west-2b"
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}