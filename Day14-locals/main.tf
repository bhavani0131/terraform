variable "region" {
  default = "us-east-1"
}

locals {
  region        = var.region
  instance_type = "t3.micro"
  ami_id        = "ami-0521cb2d60cfbb1a6"
}

# 1. Define the Provider using your local region variable
provider "aws" {
  region = local.region
}

# 2. Create the VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# 3. Create a Subnet inside the VPC
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # Gives your EC2 a public IP
  availability_zone       = "${local.region}a" # Sets it to us-east-1a to avoid unsupported zone errors

  tags = {
    Name = "public-subnet"
  }
}

# 4. Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# 5. Create a Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "main-route-table"
  }
}

# 6. Associate the Route Table with your Subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rt.id
}

# 7. Your EC2 Instance
resource "aws_instance" "name" {
  ami           = local.ami_id
  instance_type = local.instance_type
  
  # Pointing directly to your active custom subnet
  subnet_id     = aws_subnet.public_subnet.id 

  tags = {
    Name = "dev"
  }
}