variable "ami_id" {
  type        = string
  description = "The AMI ID for the EC2 instance"
  default     = "ami-00e801948462f718a"
}

variable "instance_type" {
  type        = string
  description = "The size of the instance"
  default     = "t3.small"
}

variable "name" {
  type        = string
  description = "The name tag for the EC2 instance"
  default     = "my-ec2-instance"
}