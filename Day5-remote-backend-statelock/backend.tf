terraform {
  backend "s3" {
    bucket = "bhavanistatebucket"
    key = "terraform.tfstate"
    dynamodb_table = "bhavani"
    encrypt = true
    use_lockfile = true #native locking process to prevent cocurrent state modification
    region = "us-east-1"
  }
}
#supports latest version >=1.10
#<1.10 we can use dynamodb for state locking as well, but s3 native locking is more efficient and cost effective
#State lockfile: Terraform acquires a state lock to protect the state from being written by multiple users at the same. Please resolve the above issue and