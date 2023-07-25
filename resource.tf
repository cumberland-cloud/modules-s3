resource "aws_s3_bucket" "this" {
    bucket                      = var.bucket.name
}

resource "aws_s3_bucket_acl" "this" {
    bucket                      = aws_s3_bucket.this.id
    acl                         = var.bucket.acl
    expected_bucket_owner       = "BucketOwnerEnforced"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
    count                       = var.bucket.kms_key_arn == null ? 0 : 1

    bucket                      = aws_s3_bucket.this.id
    expected_bucket_owner       = "BucketOwnerEnforced"

    rule {
        apply_server_side_encryption_by_default {
            kms_master_key_id   = var.bucket.kms_key_arn
            sse_algorithm       = "aws:kms"
        }
    }
}

resource "aws_s3_bucket_versioning" "state" {
    bucket                      = aws_s3_bucket.this.id

    versioning_configuration {
        status                  = "Enabled"
    }
}

resource "aws_s3_bucket_policy" "this" {
    count                       = var.bucket.policy == null ? 0 : 1
    
    bucket                      = aws_s3_bucket.this.id
    policy                      = var.bucket.policy
}