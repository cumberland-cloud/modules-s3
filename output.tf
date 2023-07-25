output "bucket" {
    value       = {
        id      = aws_s3_bucket.this.id
        arn     = aws_s3_bucket.this.arn
    }
}