data "aws_iam_policy_document" "merged" {
    count                   = local.conditions.merge_policies ? 1 : 0

    source_policy_documents = [
        aws_iam_policy_document.unmerged.json,
        var.bucket.policy
    ]
}

data "aws_iam_policy_document" "unmerged" {
  statement {
    sid                     = "EnableIAMPerms"
    effect                  = "Allow"
    actions                 = [ "s3:*" ]
    resources               = [ "*" ]

    principals {
      type                  =  "AWS"
      identifiers           = [
        "arn:aws:iam::${data.aws_caller_identity.account_id}:root"
      ]
    }
  }

  statement {
    sid                     = "DenyACLActions"
    effect                  = "Deny"
    actions                 = [
      "s3:PutBucketAcl",
      "s3:PutObjectAcl",
      "s3:PutObjectVersionAcl"
    ]
    resources               = [ "*" ]
  }

  statement {
    sid                     = "DenyDeleteActions"
    effect                  = "Deny"
    actions                 = [
      "s3:DeleteBucket"
    ]
    resources               = [ "*" ]
  }
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect                  = "Allow"
    actions                 = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]
    resources               = [ local.local.source_bucket_arn ]
  }

  statement {
    effect                  = "Allow"
    actions                 = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging"
    ]
    resources               = ["${local.local.source_bucket_arn}/*"]
  }

  statement {
    effect                  = "Allow"
    actions                 = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags"
    ]
    resources = local.destination_bucket_arns
  }
}