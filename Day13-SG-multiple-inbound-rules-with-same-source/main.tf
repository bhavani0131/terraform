resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Bhavani-VPC"
  }
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_security_group" "main" {
  name        = "My-SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id 

  ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000, 8082, 8081] : {
      description      = "inbound rules"
      from_port        = port
      to_port          = port
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "main" {
  ami           = "ami-0521cb2d60cfbb1a6"
  instance_type = "t3.micro" 
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  tags = {
    Name = "Bhavani-EC2"
  }
}