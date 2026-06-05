variable "ami_id" {
  description = "EC2 instance AMI ID"
  type = string
  default = ""
}
variable "instance_type" {
  description = "Instance type for EC2 instace"
  type = string
  default = ""
}
variable "name" {
  description = "EC2 instance name"
  type = string
  default = ""
}