//Creating our variables for our 2-tier architecture 
// First region 
variable "region1" {
  type = string 
  default= "eu-west-2a"
}
//second region 
variable "region2" {
  type = string
  default = "eu-west-2b"
}

variable "ec2-instance-type" {
  type = string
  default = "t2.micro"
}

variable "ec2-ami" {
  type = string 
  default = "ami-0aaa5410833273cfe"
}
//------------------------------------------------------
//vpc CIDR block
variable "vpcCIDR" {
  type = string 
  default = "10.0.0.0/16"
}

// create 2 public subnets and CIDR blocks
variable "public_subnet_1a" {
  type = string
  default = "10.0.1.0/24"
}
variable "public_subnet_1b" {
  type = string
  default = "10.0.2.0/24"
}
//create 2 private subnets and CIDR blocks
variable "private_subnet_1a" {
  type = string
  default = "10.0.3.0/24" 
}

variable "private_subnet_1b" {
  type = string
  default = "10.0.4.0/24" 
}

//------------------------------------------------------
//RDS database values
variable "usernameRDS" {
  type = string 
}

variable "passwordRDS" {
  type = string 
  sensitive = true
}

variable "db_name" {
  type = string
}

//------------------------------------------------------
//EC2 instances 

variable "app_name" {
  type = string 
  default = "web-app"
}

//------------------------------------------------------
//route 53 
variable "domain" {
  type = string
}


