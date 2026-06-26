provider "aws" {
 region = "ap-south-2"
}

resource "aws_instance" "dev" {
    ami = "ami-01f3f4b95d125a9af"
    instance_type = "t3.micro"
    tags = {
      Name = "Bhavani"
    }
}


 terraform {
   backend "s3" {
     bucket = "bhavani-terraform-state-bucket"   # Replace with your bucket name
     key    = "terraform.tfstate"
     region = "ap-south-2"
   }
 }

#resource "aws_s3_bucket" "terraform_state" {
#  bucket = "bhavani-terraform-state-bucket"   # Must be globally unique

#  tags = {
#    Name = "Terraform State Bucket"
#  }
#}

#resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
#  bucket = aws_s3_bucket.terraform_state.id

# versioning_configuration {
#    status = "Enabled"
#  }
#}

#resource "aws_s3_bucket_public_access_block" "terraform_state_public_access" {
#  bucket = aws_s3_bucket.terraform_state.id

#  block_public_acls       = true
#  ignore_public_acls      = true
#  block_public_policy     = true
#  restrict_public_buckets = true
#}





