varible "bucket" {
    description     = "Bucket configuration. Policy should be a JSON string. Policy will be merged with default policy that denies any CRUD ACL operations."
    type            = object({
        name        = string
        acl         = optional(string, "private")
        kms_key_arn = optional(string, null)
        policy      = optional(string, null)
    })
}