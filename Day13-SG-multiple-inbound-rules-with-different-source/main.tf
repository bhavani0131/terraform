provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "My-VPC"
  }
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "${var.aws_region}a"
}

resource "aws_security_group" "main" {
  name        = "Bhavani-SG"
  description = "Allow inbound traffic on specific ports with designated sources"
  vpc_id      = aws_vpc.main.id

  # Loop dynamically over the map variable
  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      description = "Allow traffic on port ${ingress.key}"
      from_port   = tonumber(ingress.key) # Converts string key to number type
      to_port     = tonumber(ingress.key)
      protocol    = "tcp"
      cidr_blocks = [ingress.value]       # Assigns the unique CIDR mapping
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bhavani-SG"
  }
}

resource "aws_instance" "main" {
  ami                    = "ami-0521cb2d60cfbb1a6"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  
  tags = {
    Name = "My-EC2"
  }
}