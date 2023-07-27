data "aws_caller_identity" "current" {}

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