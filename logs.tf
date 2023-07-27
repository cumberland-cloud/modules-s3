resource "aws_s3_bucket" "logs" {
    #checkov:skip=CKV2_AWS_61: "Ensure that an S3 bucket has a lifecycle configuration"
    #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"

    bucket                      = "${var.bucket.name}-logs"
    
    lifecycle {
        prevent_destroy         = true
    }

}

resource "aws_s3_bucket_public_access_block" "logs" {
    bucket                      = aws_s3_bucket.logs.id
    block_public_acls           = true
    block_public_policy         = true
    ignore_public_acls          = true
    restrict_public_buckets     = true
}

resource "aws_s3_bucket_acl" "logs" {
    bucket                      = aws_s3_bucket.logs.id
    acl                         = "log-delivery-write"
    expected_bucket_owner       = "BucketOwnerEnforced"
}

resource "aws_s3_bucket_versioning" "logs" {
    bucket                      = aws_s3_bucket.logs.id

    versioning_configuration {
        status                  = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
    bucket                      = aws_s3_bucket.logs.id
    expected_bucket_owner       = "BucketOwnerEnforced"

    rule {
        apply_server_side_encryption_by_default {
            kms_master_key_id   = local.encryption_configuration.arn
            sse_algorithm       = "aws:kms"
        }
    }
}
