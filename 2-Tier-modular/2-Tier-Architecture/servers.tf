//create our 2 servers
resource "aws_instance" "server1" {
  ami                         = var.ec2-ami //Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-02-08
  instance_type               = var.ec2-instance-type
  availability_zone           = var.region1
  subnet_id                   = aws_subnet.public_subnet_1a.id
  vpc_security_group_ids      = [aws_security_group.publicsg.id]
  associate_public_ip_address = true

  user_data  = <<-EOF
              #!/bin/bash
              echo "Hello from server 1, congrats you have reached this EC2" > index.html
              python3 -m http.server 8080 &
              EOF
}

//set up our second ec2 instance in our public subnet 1b 
resource "aws_instance" "server2" {
  ami                         = var.ec2-ami
  instance_type               = var.ec2-instance-type
  availability_zone           = var.region2
  subnet_id                   = aws_subnet.public_subnet_1b.id
  vpc_security_group_ids      = [aws_security_group.publicsg.id]
  associate_public_ip_address = true

    user_data  = <<-EOF
              #!/bin/bash
              echo "Hello from server 2, congrats you have reached this EC2" > index.html
              python3 -m http.server 8080 &
              EOF


}