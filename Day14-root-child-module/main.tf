provider "aws" {
  region = "us-east-1"
}

module "web_server" {
  source = "./modules/ec2"

  instance_name = "my-web-server"
  ami_id         = "ami-0521cb2d60cfbb1a6"
  instance_type  = "t3.micro"
}