//output our public security group 
output "publicsg" {
  value = aws_security_group.publicsg.id
}
//public subnet 
output "public_subnet_1a" {
  value = aws_subnet.public_subnet_1a.id
}
//public subnet 
output "public_subnet_1b" {
  value = aws_subnet.public_subnet_1b.id
}
//private subnet 
output "private_subnet_1a" {
  value = aws_subnet.private_subnet_1a.id
}
//private subnet 
output "private_subnet_1b" {
  value = aws_subnet.private_subnet_1b.id
}
//private security group for RDS instance 
output "privatesg" {
  value = aws_security_group.privatesg.id
}
//EC2 server 
output "server1" {
  value = aws_instance.server1.id
}
//EC2 server 
output "server2" {
  value = aws_instance.server2.id
}
//load balancer 
output "loadb" {
  value = aws_lb.loadb.id
}