resource "aws_s3_bucket" "this" {
    bucket                      = var.bucket.name
}

resource "aws_s3_bucket_acl" "this" {
    bucket                      = aws_s3_bucket.this.id
    acl                         = var.bucket.acl
    expected_bucket_owner       = "BucketOwnerEnforced"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
    bucket                      = aws_s3_bucket.this.id
    expected_bucket_owner       = "BucketOwnerEnforced"

    rule {
        apply_server_side_encryption_by_default {
            kms_master_key_id   = local.encryption_configuration.arn
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
    bucket                      = aws_s3_bucket.this.id
    policy                      = local.policy_configuration.json
}