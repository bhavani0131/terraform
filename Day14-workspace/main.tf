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
  map_public_ip_on_launch = true 
  
  # FIX: Forcing the subnet into us-east-1a where t3.micro is guaranteed to be supported
  availability_zone       = "us-east-1a"

  tags = {
    Name = "dev-public-subnet"
  }
}

# 3. Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "dev-igw"
  }
}

# 4. Create a Route Table
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

# 6. Your EC2 Instance (Using the specified AMI and type from your code)
resource "aws_instance" "name" {
  ami           = "ami-0521cb2d60cfbb1a6"
  instance_type = "t3.micro"
  
  # Links your EC2 instance to your custom network
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "Bhavani"
  }
}

# 7. AWS Provider pinned to us-east-1
provider "aws" {
  region = "us-east-1"
}