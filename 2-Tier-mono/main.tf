#initialise terraform version and providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider in my region 
provider "aws" {
  region = "eu-west-2"
}

#create vpc with specified CIDR block 
resource "aws_vpc" "vpc" {

  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    "name" = "vpc"
  }
}
# create ec2 instance within a different availabilty zone eu-west 2a 
resource "aws_instance" "myec21" {
  ami                         = "ami-0f540e9f488cfa27d"
  instance_type               = "t2.micro"
  availability_zone           = "eu-west-2a"
  subnet_id                   = aws_subnet.publicsubnet.id
  vpc_security_group_ids      = [aws_security_group.publicsg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
        #!/bin/bash
        yum update -y
        yum install httpd -y
        systemctl start httpd
        systemctl enable httpd
        echo "<html><body><h1>First instance successfully deployed</h1></body></html>" > /var/www/html/index.html
        EOF


}

#create public subnet within our VPC with specified CIDR in eu-west-1 and eu-west-3
resource "aws_subnet" "publicsubnet" {
  vpc_id = aws_vpc.vpc.id

  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "publicsubnet"
  }

}

resource "aws_instance" "myec22" {
  ami                         = "ami-0f540e9f488cfa27d"
  instance_type               = "t2.micro"
  availability_zone           = "eu-west-2b"
  subnet_id                   = aws_subnet.publicsubnet2.id
  vpc_security_group_ids      = [aws_security_group.publicsg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
        #!/bin/bash
        yum update -y
        yum install httpd -y
        systemctl start httpd
        systemctl enable httpd
        echo "<html><body><h1>First instance successfully deployed</h1></body></html>" > /var/www/html/index.html
        EOF


}
resource "aws_subnet" "publicsubnet2" {
  vpc_id = aws_vpc.vpc.id

  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "publicsubnet2"
  }

}

#create private subnets within our VPC with specified CIDR in eu-central-1 and eu-north-1
resource "aws_subnet" "privatesubnet" {
  vpc_id = aws_vpc.vpc.id

  cidr_block              = "10.0.3.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "privatesubnet"
  }

}

resource "aws_subnet" "privatesubnet2" {
  vpc_id = aws_vpc.vpc.id

  cidr_block              = "10.0.4.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "privatesubnet"
  }

}

#set up internet gateway 
resource "aws_internet_gateway" "gw" {

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "gw"
  }

}
#set up routing table and allow all ip into our vpc
#make sure the routing table is connected to our internet gateway
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "rt"
  }
}
#connect our route table to our public subnets 
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.publicsubnet2.id
  route_table_id = aws_route_table.rt.id
}
#set up security group for the public to allow connections from SSH and port 80
resource "aws_security_group" "publicsg" {
  name        = "publicsg"
  description = "Allow inbound on Port 80 and SSH"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_security_group" "privatesg" {
  name        = "privatesg"
  description = "security group for allowing web tier and SSH traffic"
  vpc_id      = aws_vpc.vpc.id


  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16"]
    security_groups = [aws_security_group.publicsg.id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Security group for load balancer"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
#creating our load balancer
resource "aws_lb" "loadb" {
  name               = "loadb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.publicsubnet.id, aws_subnet.publicsubnet2.id]


}

resource "aws_lb_target_group" "lbtarget" {
  name = "lbtarget"
  # target_type = "alb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  depends_on = [aws_vpc.vpc]
}


resource "aws_alb_target_group_attachment" "albtga" {
  target_group_arn = aws_lb_target_group.lbtarget.arn
  target_id        = aws_instance.myec21.id
  port             = 80

  depends_on = [aws_instance.myec21]
}


resource "aws_alb_target_group_attachment" "albtga2" {
  target_group_arn = aws_lb_target_group.lbtarget.arn
  target_id        = aws_instance.myec22.id
  port             = 80

  depends_on = [aws_instance.myec22]
}


resource "aws_lb_listener" "lblister" {
  load_balancer_arn = aws_lb.loadb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lbtarget.arn
  }
}





