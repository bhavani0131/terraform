variable "dev" {
  type    = bool
  default = true
}

# 1. Create the VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "dev-vpc"
  }
}

# 2. Create a Subnet inside the VPC
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # Gives your EC2 a public IP

  tags = {
    Name = "dev-public-subnet"
  }
}

# 3. Create an Internet Gateway so the VPC can connect to the internet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "dev-igw"
  }
}

# 4. Create a Route Table to route traffic through the Internet Gateway
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "dev-route-table"
  }
}

# 5. Associate the Route Table with your Subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rt.id
}

variable "environment" {
  type    = string
  default = "test"
}

# Your active condition practice instance
resource "aws_instance" "example" {
  count         = var.environment == "prod" ? 3 : 1
  ami           = "ami-0521cb2d60cfbb1a6"
  instance_type = "t3.micro"
  
  # Pointing to your active custom subnet
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "example-${count.index}"
  }
}

# 6. Previous EC2 condition practice block (UNCOMMENTED)
resource "aws_instance" "name" {
  ami           = "ami-0521cb2d60cfbb1a6" 
  instance_type = "t3.micro"
  count         = var.dev ? 1 : 0

  subnet_id     = aws_subnet.public_subnet.id 

  tags = {
    Name = "dev-ec2-instance"
  }
}

provider "aws" {
  region = "us-east-1" 
}

# 7. The S3 Bucket (UNCOMMENTED)
resource "aws_s3_bucket" "dev" {
  bucket = "statefile-configuresssdsfsff"
}