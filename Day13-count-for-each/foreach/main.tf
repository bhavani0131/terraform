resource "aws_vpc" "simple_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Bhavani-VPC"
  }
}

resource "aws_subnet" "simple_subnet" {
  vpc_id            = aws_vpc.simple_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Bhavani-Subnet"
  }
}

resource "aws_security_group" "allow_all" {
  name        = "Bhavani-Allow-All"
  description = "Allow absolutely all inbound and outbound traffic"
  vpc_id      = aws_vpc.simple_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # "-1" means all protocols (TCP, UDP, ICMP, etc.)
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bhavani-Allow-All-SG"
  }
}

variable "env" {
  type = list(string)
  default = [ "dev","test" ]
}

resource "aws_instance" "name" {
  ami                    = "ami-0521cb2d60cfbb1a6"
  instance_type          = "t3.small"
  for_each = toset(var.env)
  subnet_id              = aws_subnet.simple_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]

  tags = {
    Name = each.key
  }
}
