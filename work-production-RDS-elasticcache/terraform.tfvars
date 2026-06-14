aws_region   = "us-east-1"
project_name = "myapp"
environment  = "production"

vpc_cidr = "10.20.0.0/16"
private_subnet_cidrs = [
  "10.20.1.0/24",
  "10.20.2.0/24",
  "10.20.3.0/24"
]

db_name                     = "appdb"
db_username                 = "admin"
db_password                 = "Password123" # FIX 4: added password field
db_instance_class           = "db.t3.micro"
db_replica_instance_class   = "db.t3.micro"
db_allocated_storage_gb     = 20
db_max_allocated_storage_gb = 20
db_backup_retention_days    = 1
db_engine_version           = "8.0" # AWS picks latest available minor version
enable_read_replica         = true

redis_node_type               = "cache.t3.micro"
redis_replicas_per_node_group = 0
redis_snapshot_retention_days = 0

deletion_protection = false # FIX 5: false so you can destroy later
skip_final_snapshot = true  # FIX 5: true to allow destroy without snapshot