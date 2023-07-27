varible "bucket" {
    description     = <<EOT
    S3 Bucket configuration object. 
    
    ECR configuration object. 
    
    KMS key: If no KMS key is specified for the encryption of resources, one will be provisioned. If using a pre-existing bucket, the key output from the KMS module should be passed in under the `key` object.
    
    Policy: Policy should be a JSON string. By default, a policy is generated that allows all users in the caller AWS account READ/WRITE access, with the exception of ACL operations, i.e. all ACL operations are explicitly denied. Any additional permissions passed in through the `policy` will be merged into the default policy through a `aws_iam_policy_document` data block.
    EOT
    
    type            = object({
        name        = string
        acl         = optional(string, "private")
        key         = optional(string, null)
        policy      = optional(string, null)
    })
}