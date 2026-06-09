variable "db_password" {
  description = "Password managed by you for the RDS master user."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8
    error_message = "The RDS password must be at least 8 characters long."
  }
}