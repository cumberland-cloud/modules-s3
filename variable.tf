variable "bucket" {
    description     = <<EOT
    S3 Bucket configuration object. 
        
    KMS key: If no KMS key is specified for the encryption of resources, one will be provisioned. If using a pre-existing key, the key output from the KMS module should be passed in under the `key` object.
    
    Policy: Policy should be a JSON string. By default, a policy is generated that allows all users in the caller AWS account READ/WRITE access, with the exception of ACL operations, i.e. all ACL operations are explicitly denied. Any additional permissions passed in through the `policy` will be merged into the default policy through a `aws_iam_policy_document` data block.
    
    Replicas: Number of replicas to create. The original bucket will receive `var.bucket.name` as its name, and each replica will receive the name `var.bucket.name-replica-0<var.bucket.replicas>`.
    EOT
    
    type                        = object({
        name                    = string
        acl                     = optional(string, "private")
        key                     = optional(string, null)
        notification_events     = optional(list(string), [
                                    "s3:ObjectCreated:*",
                                    "s3:ObjectRemoved:*"
                                ])
        policy                  = optional(string, null)
        replicas                = optional(number, 1)
    })
}

variable "replication_role" {
    description                 = "ARN of the replication role. This role will have a policy attached to it that will enabled s3 replication. The service principal in the trust relationship must be `s3.amazonaws.com`. The `s3_replicator` key of the IAM module `service_roles` output can be passed directly into this argument."
    type                        = object({
        arn                     = string
        id                      = string
        name                    = string 
    }) 
    default                     = {
        arn                     = "arn:aws:iam::<account-id>:role/s3-replicator"
        id                      = "s3-replicator"
        name                    = "s3-replicator"
    }
    
    validation {
        condition               = !strcontains(var.replication_role.arn, "<account-id>")
        error_message           = "The replication role ARN must include a valid account id."
    }

}