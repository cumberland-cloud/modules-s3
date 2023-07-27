output "bucket" {
    description                             = "Map containing source S3 bucket and its replicas. The lowest index will always be the source bucket, whose content will be replicated into the replica buckets."
    value                                   = {
        for bucket_key, bucket in aws_s3_bucket.this:
            bucket_key                      => {
                arn                         = bucket.arn
                id                          = bucket.id
                bucket_regional_domain_name = bucket.bucket_regional_domain_name
            } 
    }
}