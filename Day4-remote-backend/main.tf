resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "name" {
  vpc_id = aws_vpc.name.id
  cidr_block = "10.0.0.0/26"
}

resource "aws_subnet" "name2" {
  vpc_id = aws_vpc.name.id
  cidr_block = "10.0.0.64/26"
}