resource "aws_instance" "name" {
  ami           = var.ami_id        # Updated to use your new variable!
  instance_type = var.instance_type

  tags = {
    Name = var.name
  }
}