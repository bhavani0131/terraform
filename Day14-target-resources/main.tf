resource "aws_instance" "name" {
    ami           = "ami-00e801948462f718a"
    instance_type = "t2.micro"
    tags = {
        Name = "Bhavani-EC2"
    }
  
}

resource "aws_s3_bucket" "name" {
    bucket = "bhavani-bucket-1"
  
}

#terraform apply -target=aws_s3_bucket.name we can target specific resource to apply or delete 