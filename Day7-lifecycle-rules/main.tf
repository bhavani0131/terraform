resource "aws_instance" "name" {
    ami           = "ami-00e801948462f718b"
    instance_type = "t3.micro"
    
    tags = {
        Name = "EC2"
    }
  

  lifecycle {
    create_before_destroy = true
  }

# lifecycle {
#   ignore_changes = [ tags, ]
# }

# lifecycle {
#  prevent_destroy = true
# }

}

