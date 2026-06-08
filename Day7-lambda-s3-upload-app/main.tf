# 1. IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role_s3"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 2. Automatically package the code (No manual zipping needed!)
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# 3. Create the S3 Bucket
resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = "bhavani-lambda-code-bucket-2026" # Must be globally unique! Change if this name is taken.
  force_destroy = true 
}

# 4. Upload the zipped code to S3
resource "aws_s3_object" "lambda_code_upload" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "lambda_function.zip"
  source = data.archive_file.lambda_zip.output_path
  etag   = filemd5(data.archive_file.lambda_zip.output_path) # Triggers re-upload when python code changes
}

# 5. Lambda Function referencing S3
resource "aws_lambda_function" "my_lambda" {
  function_name = "my_lambda_function_via_s3"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  timeout       = 900
  memory_size   = 128

  # Tell Lambda to fetch the code from S3 instead of local disk
  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_code_upload.key

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}