variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "The AWS region to deploy resources into"
}

variable "allowed_ports" {
  type = map(string)
  default = {
    "22"   = "203.0.113.50/32"  # Example: Restrict SSH to your corporate/home IP
    "80"   = "0.0.0.0/0"        # Public HTTP traffic
    "443"  = "0.0.0.0/0"        # Public HTTPS traffic
    "3000" = "10.0.0.0/16"      # Internal application port (VPC only)
    "8080" = "0.0.0.0/0"        # Alternative web port
    "8081" = "192.168.1.0/24"   # Private management network
    "8082" = "0.0.0.0/0"
    "9000" = "0.0.0.0/0"
  }
  description = "A map of ports to their respective allowed source CIDR blocks"
}