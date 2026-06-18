 data "aws_ami" "example" {
   most_recent = true
   owners      = ["self"] # Replace with the AWS account ID if needed

   filter {
     name   = "name"
     values = ["Frontend-AMI"] # Use your AMI name pattern
   }
 }



# data "aws_ami" "amzlinux" {
#   most_recent = true
#   owners = [ "amazon" ]
#   filter {
#     name = "name"
#     values = [ "amzn2-ami-hvm-*-gp2" ]
#   }
#              filter {
#     name = "root-device-type"
#     values = [ "ebs" ]
#   }
#         filter {
#     name = "virtualization-type"
#     values = [ "hvm" ]
#   }
#   filter {
#     name = "architecture"
#     values = [ "x86_64" ]
#   }
# }

# Launch Template Resource
resource "aws_launch_template" "frontend" {
  name = "frontend-terraform"
  description = "frontend-terraform"
  #image_id = data.aws_ami.example.id
  image_id = "ami-01927894ffae91e1c"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.frontend-server-sg.id]
  key_name = "us-east-1" #chnage the key 
  #user_data = filebase64("${path.module}/frontend-lt.sh")
  #default_version = 1
  update_default_version = true
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "frontend-terraform"
    }
  }
}

###################################################################################
 data "aws_ami" "example1" {
   most_recent = true
   owners      = ["self"] # Replace with the AWS account ID if needed

   filter {
     name   = "name"
     values = ["Backend-AMI"] # Use your AMI name pattern
   }
 }

# data "aws_ami" "amzlinux-backend" {
#   most_recent = true
#   owners = [ "amazon" ]
#   filter {
#     name = "name"
#     values = [ "amzn2-ami-hvm-*-gp2" ]
#   }
#              filter {
#     name = "root-device-type"
#     values = [ "ebs" ]
#   }
#         filter {
#     name = "virtualization-type"
#     values = [ "hvm" ]
#   }
#   filter {
#     name = "architecture"
#     values = [ "x86_64" ]
#   }
# }

# Launch Template Resource
resource "aws_launch_template" "backend" {
  name = "backend-terraform"
  description = "backend-terraform"
  #image_id = data.aws_ami.example1.id
  image_id = "ami-02ecd33b30a03b4dc"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.backend-server-sg.id]
  key_name = "us-east-1" 
  #user_data = filebase64("${path.module}/backend-lt.sh")
  #default_version = 1
  update_default_version = true
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "backend-terraform"
    }
  }
}
