# NOTE: first bucket is treated as the source bucket, all other buckets are treated as replicas
resource "aws_s3_bucket" "this" {
    #checkov:skip=CKV2_AWS_61: "Ensure that an S3 bucket has a lifecycle configuration"
    count                       = local.total_buckets

    bucket                      = count.index == 0 ? (
                                    var.bucket.name
                                ) : (
                                    "${var.bucket.name}-replica-0${count.index}"
                                )
    
    lifecycle {
        prevent_destroy         = true
    }

    logging {
        target_bucket           = aws_s3_bucket.logs.id
        target_prefix           = "log/${count.index}"
    }

}

resource "aws_s3_bucket_policy" "this" {
    count                       = local.total_buckets

    bucket                      = aws_s3_bucket.this[count.index].id
    policy                      = local.policy_configuration.json
}

resource "aws_s3_bucket_public_access_block" "this" {
    count                       = local.total_buckets

    bucket                      = aws_s3_bucket.this[count.index].id
    block_public_acls           = true
    block_public_policy         = true
    ignore_public_acls          = true
    restrict_public_buckets     = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
    count                       = local.total_buckets

    bucket                      = aws_s3_bucket.this[count.index].id

    rule {
        object_ownership        = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_acl" "this" {
    count                       = local.total_buckets

    bucket                      = aws_s3_bucket.this[count.index].id
    acl                         = var.bucket.acl
    expected_bucket_owner       = data.aws_caller_identity.current.account_id
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
    count                       = local.total_buckets

    bucket                      = aws_s3_bucket.this[count.index].id
    expected_bucket_owner       = data.aws_caller_identity.current.account_id

    rule {
        apply_server_side_encryption_by_default {
            kms_master_key_id   = local.encryption_configuration.arn
            sse_algorithm       = "aws:kms"
        }
    }
}

resource "aws_s3_bucket_versioning" "this" {
    count                       = local.total_buckets

    bucket                      = aws_s3_bucket.this[count.index].id

    versioning_configuration {
        status                  = "Enabled"
    }
}

resource "aws_s3_bucket_notification" "this" {
  bucket                        = aws_s3_bucket.this[0].id

  topic {
    topic_arn                   = aws_sns_topic.this.arn
    events                      = var.bucket.notification_events
  }
}

resource "aws_s3_bucket_replication_configuration" "replication" {
    depends_on                  = [ aws_s3_bucket_versioning.this ]

    role                        = var.replication_role.arn
    bucket                      = aws_s3_bucket.this[0].id

    rule {
        status                  = "Enabled"

        dynamic "destination" {
            for_each            = { 
                for k,v in aws_s3_bucket.this:
                    k           => v if k > 0 
            }
            
            content {
                bucket          = destination.arn
                storage_class   = "STANDARD"
            }
        }
    }
}

resource "aws_iam_policy" "this" {
    name                        = "${var.bucket.name}-s3-replication-policy"
    policy                      = data.aws_iam_policy_document.replication.json
}

resource "aws_iam_role_policy_attachment" "this" {
    role                        = var.replication_role.name
    policy_arn                  = aws_iam_policy.this.arn
}

resource "aws_sns_topic" "this" {
  kms_master_key_id             = local.encryption_configuration.alias_arn
  name                          = local.event_notification_id
  policy                        = data.aws_iam_policy_document.notification.json
}