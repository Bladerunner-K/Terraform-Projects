
//create our VPC
resource "aws_vpc" "cloudvpc" {

  cidr_block = "10.0.0.0/16"

}
//set up our internet gateway into our VPC
resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.cloudvpc.id
}
//attach gateway to our vpc 
resource "aws_internet_gateway_attachment" "igwa" {
  vpc_id = aws_vpc.cloudvpc.id
  internet_gateway_id = aws_internet_gateway.igw.id
}
//create our public subnets within our VPC in eu-west-2a and eu-west-2b for high availablility
resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.cloudvpc.id

  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true


}
resource "aws_subnet" "public_subnet_1b" {
  vpc_id                  = aws_vpc.cloudvpc.id

  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true 


} 
//create our private subnets in thier respective availablilty zones matching the public subnets
resource "aws_subnet" "private_subnet_1a" {
  vpc_id                  = aws_vpc.cloudvpc.id

  cidr_block              = "10.0.3.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = false
  
  

}
resource "aws_subnet" "private_subnet_1b" {
  vpc_id                  = aws_vpc.cloudvpc.id

  cidr_block              = "10.0.4.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = false


}
//create our route table and route table associations to our public subnets
//we don't allow the outside world internet to reach our private subnets as this would be a security risk
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.cloudvpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
//connect our route table to our public subnets
resource "aws_route_table_association" "association_a" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_route_table_association" "association_b" {
  subnet_id      = aws_subnet.public_subnet_1b.id
  route_table_id = aws_route_table.rt.id
}
//VPC Security group to allow connection to our servers on our public subnets
resource "aws_security_group" "publicsg" {
  name        = "publicsg"
  description = "Allow inbound on Port 8080"
  vpc_id      = aws_vpc.cloudvpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
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
//allow for specific connections to the database on our private subnets on port 3306 from within our VPC and not the outside world
resource "aws_security_group" "privatesg" {
  name        = "privatesg"
  description = "security group for database and private subnets"
  vpc_id      = aws_vpc.cloudvpc.id


  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16"]
    security_groups = [aws_security_group.publicsg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

//create security group for our load balancer to allow connections from port 80 and will direct to the servers 
resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Security group for load balancer"
  vpc_id      = aws_vpc.cloudvpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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
//create our load balancer to operate send traffic to either one of our servers running in thier respective public subnets 
resource "aws_lb" "loadb" {
  name               = "theloadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1b.id]
}

//setting up our listener to listen on port 80, any other port and it will return an error message
resource "aws_lb_listener" "lblister" {
  load_balancer_arn = aws_lb.loadb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "page cannot be found!"
      status_code  = "404"
    }
  }
}

//setting up target group with health checker so that we can later direct the traffic to our EC2 instances 
resource "aws_lb_target_group" "lb-tg" {
  name     = "lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.cloudvpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

//Attaching EC2 to target group so we can direct traffic on port 8080
resource "aws_alb_target_group_attachment" "server1" {
  target_group_arn = aws_lb_target_group.lb-tg.arn
  target_id        = aws_instance.server1.id
  port             = 8080
}
//Attaching EC2 to target group so we can direct traffic on port 8080
resource "aws_alb_target_group_attachment" "server2" {
  target_group_arn = aws_lb_target_group.lb-tg.arn
  target_id        = aws_instance.server2.id
  port             = 8080  
}
//creating listener rule to foward traffic to instances target group
resource "aws_lb_listener_rule" "instances" {
  listener_arn = aws_lb_listener.lblister.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-tg.arn
  }
}





