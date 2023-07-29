data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "merged" {
    count                   = local.conditions.merge_policies ? 1 : 0

    source_policy_documents = [
        data.aws_iam_policy_document.unmerged.json,
        var.bucket.policy
    ]
}

data "aws_iam_policy_document" "unmerged" {
  #checkov:skip=CKV_AWS_111: "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_108: "Ensure IAM policies does not allow data exfiltration"
  #checkov:skip=CKV_AWS_356: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
    # TODO: fix CHK_AWS_108
    
  statement {
    sid                     = "EnableIAMPerms"
    effect                  = "Allow"
    actions                 = [ "s3:*" ]
    resources               = [ "${local.source_bucket_arn}*" ]

    principals {
      type                  =  "AWS"
      identifiers           = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
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
    resources               = [ "${local.source_bucket_arn}*" ]

  }

  statement {
    sid                     = "DenyDeleteActions"
    effect                  = "Deny"
    actions                 = [
      "s3:DeleteBucket"
    ]
    resources               = [ "${local.source_bucket_arn}*" ]
  }
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect                  = "Allow"
    actions                 = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]
    resources               = [ local.source_bucket_arn ]

    condition {
      test                  = "StringEquals"
      variable              = "aws:SourceAccount"
      values                = [ data.aws_caller_identity.current.account_id ]
    }
  }

  statement {
    effect                  = "Allow"
    actions                 = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging"
    ]
    resources               = ["${local.source_bucket_arn}/*"]

    condition {
      test                  = "StringEquals"
      variable              = "aws:SourceAccount"
      values                = [ data.aws_caller_identity.current.account_id ]
    }
  }

  statement {
    effect                  = "Allow"
    actions                 = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags"
    ]
    resources = local.destination_bucket_arns
    
    condition {
      test                  = "StringEquals"
      variable              = "aws:SourceAccount"
      values                = [ data.aws_caller_identity.current.account_id ]
    }
  }
}

data "aws_iam_policy_document" "notification" {
  statement {
    effect                  = "Allow"
    actions                 = [ "sns:Publish"]
    resources               = [ local.event_notification_arn ]

    condition {
      test                  = "ArnLike"
      variable              = "aws:SourceArn"
      values                = [ aws_s3_bucket.this[0].arn ] 
    }

    principals {
      type                  = "*"
      identifiers           = [ "*" ]
    }
  }
}