//setting up Amazon RDS instance within our private subnet 
resource "aws_db_instance" "mydb" {
  allocated_storage      = 10
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  username               = var.usernameRDS
  password               = var.passwordRDS
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.privatesg.id]
  db_subnet_group_name = aws_db_subnet_group.dbsunet.id
  skip_final_snapshot    = true
}

//create our database subnet group and associate our 2 already created private subnets to it
resource "aws_db_subnet_group" "dbsunet" {
  subnet_ids = [aws_subnet.private_subnet_1a.id, aws_subnet.private_subnet_1b.id]
}
