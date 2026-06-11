resource "aws_instance" "Bhavani-EC2" {
  ami           = "ami-09e69ca1171857250"
  instance_type = "t3.micro"
  tags = {
        Name = "Bhavani-EC2"
    }
}

resource "aws_s3_bucket" "name" {
   bucket = "bhavani-bucket-999" 
}

resource "aws_s3_bucket_versioning" "name" {
    bucket = aws_s3_bucket.name.id
    versioning_configuration {
        status = "Suspended"
    }
}