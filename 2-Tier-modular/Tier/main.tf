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

variable "passwordRDS" {
  type = string
  sensitive = true
}


//deploy our first server 
module "_Teir_Architecture" {
  source = "../2-Teir-Architecture "

  # Input Variables
  app_name             = "web-app-1"
  domain               = "www.khalidtheone.com"
  ec2-instance-type    = "t2.micro"
  db_name              = "webapplication1db"
  usernameRDS          = "techno"
  passwordRDS          = var.passwordRDS
}

//deploy our second server 
//module "_Teir_Architecture_2" {
  //source = "../2-Teir-Architecture "

  # Input Variables
  //app_name             = "web-app-2"
  //domain               = "www.khalidthetwo.com"
  //ec2-instance-type    = "t2.micro"
  //db_name              = "webapplication2db"
  //usernameRDS          = "retro"
  //passwordRDS          = var.passwordRDS
///}
