variable "ami_id" {
  type        = string
  description = "The AMI ID for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "The size of the instance"
}

variable "name" {
  type        = string
  description = "The name tag for the EC2 instance"
}