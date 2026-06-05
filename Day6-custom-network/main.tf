#VPC creation
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Bhavani-VPC"
  }
}
#Subnets creation
resource "aws_subnet" "main1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Public-Subnet"
  }
}
resource "aws_subnet" "main2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private-Subnet"
  }
}
#Internet Gateway creation
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Bhavani-IG"
  }
}
#Route Table creation (Public)
resource "aws_route_table" "main1" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Bhavani-RT"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}
#Subnet Association (public)
resource "aws_route_table_association" "main1" {
  subnet_id = aws_subnet.main1.id
  route_table_id = aws_route_table.main1.id
}
#NAT Gateway creation
resource "aws_nat_gateway" "main" {
  connectivity_type = "private"   
  subnet_id = aws_subnet.main1.id
  tags = {
    Name = "Bhavani-NAT"
  }
}
#Route Table creation (Private)
resource "aws_route_table" "main2" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Bhavani-NAT"
  }
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
}
#Subnet Association (private)
resource "aws_route_table_association" "main2" {
  subnet_id = aws_subnet.main2.id
  route_table_id = aws_route_table.main2.id
}
#Security Group creation
resource "aws_security_group" "main" {
  name = "Bhavani-SG"
  description = "Allow SSh and HTTP traffic"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#Ec2 Instance creation in Public subnet
resource "aws_instance" "main" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.main1.id
    vpc_security_group_ids = [aws_security_group.main.id]
    tags = {
      Name = var.name
    }
}
#RDS Subnet Group creation
resource "aws_db_subnet_group" "main" {
  name       = "bhavani-db-subnet-group"
  subnet_ids = [aws_subnet.main1.id, aws_subnet.main2.id]

  tags = {
    Name = "Bhavani-DB-Subnet-Group"
  }
}
#Security Group for RDS MySQL
resource "aws_security_group" "rds" {
  name        = "Bhavani-RDS-SG"
  description = "Allow inbound traffic from EC2 to MySQL RDS"
  vpc_id      = aws_vpc.main.id # Reuses your existing VPC

#Inbound rule: Only allows your EC2 instance's security group to connect
  ingress {
    from_port       = 3306 #Default port for MySQL
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.main.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bhavani-RDS-SG"
  }
}

#RDS Database Instance (MySQL)
resource "aws_db_instance" "main" {
  allocated_storage     = 20
  max_allocated_storage = 100 
  db_name               = "bhavanidb"
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.t4g.micro"
  username              = "admin"
  password              = "Password123"
  
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  skip_final_snapshot  = true 
  publicly_accessible  = false 

  tags = {
    Name = "Bhavani-RDS-Instance"
  }
}