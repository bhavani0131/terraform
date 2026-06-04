terraform {
  backend "s3" {
    bucket = "bhavanistatebucket"
    key = "terraform.tfstate"
    use_lockfile = true #native locking process to prevent cocurrent state modification
    region = "us-east-1"
  }
}