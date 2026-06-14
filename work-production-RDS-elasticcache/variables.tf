variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name used for resource naming."
  type        = string
  default     = "prod-data"
}

variable "environment" {
  description = "Environment name used in tags and resource names."
  type        = string
  default     = "production"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "environment must be one of: development, staging, production."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs. Use at least two subnets in different AZs."
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "Provide at least two private subnet CIDRs for multi-AZ RDS and ElastiCache."
  }
}

variable "app_ingress_cidr_blocks" {
  description = "Optional CIDRs allowed to reach the application security group."
  type        = list(string)
  default     = []
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "RDS master username."
  type        = string
  default     = "adminuser"
  sensitive   = true
}

# NEW: Added since manage_master_user_password was removed from rds.tf
variable "db_password" {
  description = "RDS master password. Must be at least 8 characters."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Primary RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_replica_instance_class" {
  description = "Read replica RDS instance class. Only used when enable_read_replica is true."
  type        = string
  default     = "db.t3.micro"
}

# MODIFIED: Changed to true to deploy the read replica block
variable "enable_read_replica" {
  description = "Set to true to create a read replica. Not supported on Free Tier."
  type        = bool
  default     = true # 👈 CHANGED FROM false TO true
}

variable "db_allocated_storage_gb" {
  description = "Initial allocated RDS storage in GB. Free Tier max is 20 GB."
  type        = number
  default     = 20
}

variable "db_max_allocated_storage_gb" {
  description = "Maximum RDS autoscaled storage in GB. Free Tier max is 20 GB."
  type        = number
  default     = 20

  validation {
    condition     = var.db_max_allocated_storage_gb >= var.db_allocated_storage_gb
    error_message = "db_max_allocated_storage_gb must be >= db_allocated_storage_gb."
  }
}

variable "db_engine_version" {
  description = "MySQL engine version."
  type        = string
  default     = "8.0"
}

# MODIFIED: Set to 1 because replicas require transaction logs from backups
variable "db_backup_retention_days" {
  description = "Number of days to retain automated RDS backups. Must be 0 for Free Tier."
  type        = number
  default     = 1 # 👈 CHANGED FROM 0 TO 1 TO REQUIRE BACKUPS FOR REPLICA

  validation {
    condition     = var.db_backup_retention_days >= 0 && var.db_backup_retention_days <= 35
    error_message = "db_backup_retention_days must be between 0 and 35."
  }
}

variable "deletion_protection" {
  description = "Enable deletion protection for production resources."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Set true only for non-production teardown."
  type        = bool
  default     = true

  validation {
    condition     = !(var.skip_final_snapshot == true && var.deletion_protection == true)
    error_message = "skip_final_snapshot cannot be true when deletion_protection is true."
  }
}

variable "redis_node_type" {
  description = "ElastiCache Redis node type."
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_replicas_per_node_group" {
  description = "Number of Redis read replicas. Set to 0 for Free Tier."
  type        = number
  default     = 0

  validation {
    condition     = var.redis_replicas_per_node_group >= 0
    error_message = "redis_replicas_per_node_group must be 0 or greater."
  }
}

variable "redis_engine_version" {
  description = "Redis engine version for ElastiCache."
  type        = string
  default     = "7.1"
}

variable "redis_snapshot_retention_days" {
  description = "Number of days to retain Redis snapshots. 0 for Free Tier."
  type        = number
  default     = 0

  validation {
    condition     = var.redis_snapshot_retention_days >= 0 && var.redis_snapshot_retention_days <= 35
    error_message = "redis_snapshot_retention_days must be between 0 and 35."
  }
}