output "bucket" {
    value                               = {
        id                              = aws_s3_bucket.this.id
        arn                             = aws_s3_bucket.this.arn
        bucket_regional_domain_name     = aws_s3_bucket.this.bucket_regional_domain_name
    }
}