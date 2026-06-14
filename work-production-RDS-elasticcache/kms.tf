resource "aws_kms_key" "data" {
  description             = "KMS key for ${local.name_prefix} RDS and Redis encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  # ADD THIS POLICY BLOCK TO SOLVE THE ACCESSDENIED EXCEPTION 👇
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          # Allows your root account identity and structural IAM roles to manage this key
          AWS = "arn:aws:iam::350758825711:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs to use the key"
        Effect = "Allow"
        Principal = {
          # Grants the CloudWatch logging engine access to perform cryptographic operations
          Service = "logs.us-east-1.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-data-key"
  }
}

resource "aws_kms_alias" "data" {
  name          = "alias/${local.name_prefix}-data"
  target_key_id = aws_kms_key.data.key_id
}