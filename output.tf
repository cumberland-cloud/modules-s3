output "bucket" {
    description                             = "Map containing metadata for the source S3 bucket and its replicas. The smallest index/key of the map will always be the source bucket, whose content will be replicated into the rest of the buckets in the map."
    value                                   = {
        for bucket_key, bucket in aws_s3_bucket.this:
            bucket_key                      => {
                arn                         = bucket.arn
                id                          = bucket.id
                bucket_regional_domain_name = bucket.bucket_regional_domain_name
            } 
    }
}