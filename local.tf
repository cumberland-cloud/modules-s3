locals {
    # Constants
    total_buckets                   = var.bucket.replicas + 1
    source_bucket_arn               = "arn:aws:s3:::${var.bucket.name}-000"
    destination_bucket_arns         = [ 
        for i in range(1, total_buckets): 
            "arn:aws:s3:::${var.bucket.name}-00${i}/*" 
    ]
    # Calculations
    conditions                      = {
        merge_policies              = var.bucket.policy != null
        provision_key               = var.bucket.key == null
    }
    # Configurations
    encryption_configuration        = local.conditions.provision_key ? (
                                        module.kms[0].key 
                                    ) : (
                                        var.bucket.key
                                    )
    policy_configuration            = local.conditions.merge_policies ? (
                                        data.aws_iam_policy_document.merged[0]
                                    ) : ( 
                                        data.aws_iam_policy_document.unmerged
                                    )
}