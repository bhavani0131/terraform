terraform {
  backend "s3" {
    bucket = "bhavanistatebucket"
    key = "terraform.tfstate"
    region = "us-east-1"
  }
}