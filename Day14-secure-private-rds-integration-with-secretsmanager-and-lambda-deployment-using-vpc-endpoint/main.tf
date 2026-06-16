terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Replace with your preferred region
}

# ==========================================
# 1. NETWORKING (VPC & SUBNETS)
# ==========================================

data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "private-lambda-rds-vpc" }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = { Name = "private-subnet-1" }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = { Name = "private-subnet-2" }
}

resource "aws_db_subnet_group" "rds" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

# ==========================================
# 2. SECURITY GROUPS
# ==========================================

# Lambda Security Group
resource "aws_security_group" "lambda_sg" {
  name        = "lambda-sg"
  description = "Security Group for Lambda Function"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Security Group (MySQL Port 3306)
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow inbound MySQL traffic from Lambda only"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306 
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }
}

# Secrets Manager VPC Endpoint Security Group
resource "aws_security_group" "vpce_sg" {
  name        = "secretsmanager-vpce-sg"
  description = "Allow HTTPS inbound from Lambda"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }
}

# ==========================================
# 3. AWS SECRETS MANAGER & VPC ENDPOINT
# ==========================================

# Secret definition
resource "aws_secretsmanager_secret" "db_secret" {
  name                    = "secure-database-credentials"
  recovery_window_in_days = 0 
}

# Values match the actual MySQL database settings below
resource "aws_secretsmanager_secret_version" "db_secret_val" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = "admin"
    password = "Password123" 
  })
}

# VPC Endpoint for Secrets Manager
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  security_group_ids = [aws_security_group.vpce_sg.id]

  tags = { Name = "secretsmanager-endpoint" }
}

data "aws_region" "current" {}

# ==========================================
# 4. AMAZON RDS INSTANCE (MYSQL FREE TIER)
# ==========================================

resource "aws_db_instance" "mysql" {
  identifier             = "private-mysql-db"
  allocated_storage      = 20                  # Free Tier supports up to 20 GB of SSD Storage
  engine                 = "mysql"
  engine_version         = "8.0"               # Standard MySQL 8.0 engine
  instance_class         = "db.t3.micro"       # Free Tier eligible instance type
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  
  username               = "admin"
  password               = "Password123"
  
  skip_final_snapshot    = true
  publicly_accessible    = false
}

# ==========================================
# 5. AWS LAMBDA FUNCTION & DATABASE LAYER
# ==========================================

resource "aws_iam_role" "lambda_role" {
  name = "lambda-vpc-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_core" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "lambda_secrets_policy" {
  name = "lambda-secrets-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = [aws_secretsmanager_secret.db_secret.arn]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_secrets" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_secrets_policy.arn
}

# 🛠️ FIXED FOR WINDOWS: Installs dependencies using native PowerShell compatibility routing
resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command     = "pip install pymysql -t layer/python"
    interpreter = ["PowerShell", "-Command"]
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

# 🛠️ Zips the downloaded python database driver
data "archive_file" "layer_zip" {
  type        = "zip"
  source_dir  = "${path.module}/layer"
  output_path = "${path.module}/pymysql_layer.zip"
  
  depends_on = [null_resource.install_dependencies]
}

# 🛠️ Deploys the package as a dedicated reusable Lambda Layer
resource "aws_lambda_layer_version" "mysql_driver_layer" {
  filename            = data.archive_file.layer_zip.output_path
  layer_name          = "pymysql-database-driver"
  compatible_runtimes = ["python3.13"]
  source_code_hash    = data.archive_file.layer_zip.output_base64sha256
}

# 🛠️ FIXED: Generates code that physically CREATES the missing database architecture components
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"
  
  source {
    content  = <<EOF
import os
import json
import boto3
import pymysql

def lambda_handler(event, context):
    secret_name = os.environ['SECRET_NAME']
    db_host = os.environ['DB_HOST']
    
    # 1. Fetch secrets privately via Interface VPC Endpoint
    secrets_client = boto3.client('secretsmanager')
    try:
        secret_response = secrets_client.get_secret_value(SecretId=secret_name)
        credentials = json.loads(secret_response['SecretString'])
        db_user = credentials['username']
        db_password = credentials['password']
    except Exception as e:
        return {'statusCode': 500, 'body': f"Failed fetching secret: {str(e)}"}

    # 2. Establish private DB connection and build structures inside MySQL
    try:
        connection = pymysql.connect(
            host=db_host,
            user=db_user,
            password=db_password,
            connect_timeout=5,
            autocommit=True # Saves table records and actions immediately
        )
        
        with connection.cursor() as cursor:
            # Create structural database components if missing
            cursor.execute("CREATE DATABASE IF NOT EXISTS practice_db;")
            cursor.execute("USE practice_db;")
            
            # Create a user table schema layout
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS users (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    name VARCHAR(50) NOT NULL,
                    email VARCHAR(50) NOT NULL
                );
            """)
            
            # Seed our practice record inside the users array table
            cursor.execute("INSERT INTO users (name, email) VALUES ('Durga Bhavani', 'durga@example.com');")
            
            # Read everything back to confirm it works
            cursor.execute("SELECT * FROM users;")
            all_users = cursor.fetchall()
            
        connection.close()
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'status': 'Success',
                'message': 'Database and users table created successfully!',
                'current_rows_in_db': all_users
            })
        }
    except Exception as e:
        return {'statusCode': 500, 'body': f"Database Action Error: {str(e)}"}
EOF
    filename = "lambda_function.py"
  }
}

resource "aws_lambda_function" "vpc_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "vpc-rds-client"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.13" 
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  vpc_config {
    subnet_ids         = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  layers = [aws_lambda_layer_version.mysql_driver_layer.arn]

  environment {
    variables = {
      DB_HOST     = aws_db_instance.mysql.address
      SECRET_NAME = aws_secretsmanager_secret.db_secret.name
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_vpc_core]
}