locals {
    # Constants
    total_buckets                   = var.bucket.replicas + 1
    source_bucket_arns               = [
        "arn:aws:s3:::${var.bucket.name}",
         "arn:aws:s3:::${var.bucket.name}/*"
    ]
    destination_bucket_arns         = [ 
        for i in range(1, local.total_buckets): 
            "arn:aws:s3:::${var.bucket.name}-replica-0${i}" 
    ]
    destination_bucket_path_arns    = [
        for i in range(1, local.total_buckets): 
            "arn:aws:s3:::${var.bucket.name}-replica-0${i}/*"
    ]
    event_notification_id           = "${var.bucket.name}-notifications"
    event_notification_arn          = "arn:aws:sns:*:*:${local.event_notification_id}"
    # Calculations
    conditions                      = {
        merge_policies              = var.bucket.policy != null
        provision_key               = var.bucket.key == null
    }
    # Configurations
    encryption_configuration        = local.conditions.provision_key ? (
                                        module.key[0].key 
                                    ) : (
                                        var.bucket.key
                                    )
    policy_configuration            = local.conditions.merge_policies ? (
                                        data.aws_iam_policy_document.merged
                                    ) : ( 
                                        data.aws_iam_policy_document.unmerged
                                    )
}