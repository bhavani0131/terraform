module "s3_bucket" {
  source = "github.com/bhavani0131/terraform-aws-s3-bucket.git"

  bucket = var.bucket_name
  acl    = var.acl

  control_object_ownership = var.control_object_ownership
  object_ownership         = var.object_ownership

  versioning = {
    enabled = var.versioning_enabled
  }
}