variable "bucket_name" {
  description = "The name of the S3 bucket. Must be globally unique."
  type        = string
  default     = "bhavani-bucket-222"
}

variable "acl" {
  description = "The canned ACL to apply to the bucket."
  type        = string
  default     = "private"
}

variable "control_object_ownership" {
  description = "Whether to manage S3 Bucket Ownership Controls."
  type        = bool
  default     = true
}

variable "object_ownership" {
  description = "Object ownership management configuration."
  type        = string
  default     = "ObjectWriter"
}

variable "versioning_enabled" {
  description = "State of versioning configuration."
  type        = bool
  default     = true
}