resource "aws_db_parameter_group" "mysql" {
  name   = "${local.name_prefix}-mysql8"
  family = "mysql8.0"

  parameter {
    name  = "require_secure_transport"
    value = "ON"
  }

  tags = {
    Name = "${local.name_prefix}-mysql8"
  }
}

# Kept for paid account use — not used on Free Tier
resource "aws_iam_role" "rds_monitoring" {
  name = "${local.name_prefix}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_instance" "primary" {
  identifier = "${local.name_prefix}-mysql-primary"

  engine         = "mysql"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password # FIX 1: Added password since manage_master_user_password is removed

  allocated_storage = var.db_allocated_storage_gb
  storage_type      = "gp2" # Free Tier only supports gp2
  storage_encrypted = false # KMS not supported on Free Tier

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az               = false

  # manage_master_user_password = true  # uncomment for paid accounts
  parameter_group_name = aws_db_parameter_group.mysql.name

  backup_retention_period   = var.db_backup_retention_days # Uses your fixed default value of 1 from variables.tf
  backup_window             = "03:00-04:00"
  maintenance_window        = "sun:04:00-sun:05:00"
  copy_tags_to_snapshot     = true
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.name_prefix}-mysql-primary-final"

  enabled_cloudwatch_logs_exports = ["error", "slowquery"]

  # FIX 2: monitoring_role_arn must be removed when monitoring_interval = 0
  monitoring_interval = 0
  # monitoring_role_arn = aws_iam_role.rds_monitoring.arn  # uncomment for paid accounts

  # FIX 3: must be explicitly set to false — not just commented out
  performance_insights_enabled = false
  # performance_insights_kms_key_id = aws_kms_key.data.arn  # uncomment for paid accounts

  auto_minor_version_upgrade = true
  apply_immediately          = true # 👈 Changed from false to true to force immediate deployment changes

  tags = {
    Name = "${local.name_prefix}-mysql-primary"
    Role = "primary"
  }
}

resource "aws_db_instance" "read_replica" {
  count = var.enable_read_replica ? 1 : 0

  identifier          = "${local.name_prefix}-mysql-replica-1"
  replicate_source_db = aws_db_instance.primary.identifier
  instance_class      = var.db_replica_instance_class

  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  storage_type           = "gp2"
  storage_encrypted      = false

  backup_retention_period   = var.db_backup_retention_days
  backup_window             = "05:00-06:00"
  maintenance_window        = "sun:06:00-sun:07:00"
  copy_tags_to_snapshot     = true
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.name_prefix}-mysql-replica-final"

  enabled_cloudwatch_logs_exports = ["error", "slowquery"]
  monitoring_interval             = 0
  performance_insights_enabled    = false

  auto_minor_version_upgrade = true
  apply_immediately          = true # 👈 Aligned to true here as well to maintain consistency

  tags = {
    Name = "${local.name_prefix}-mysql-replica-1"
    Role = "read-replica"
  }
}