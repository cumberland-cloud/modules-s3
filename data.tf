data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "merged" {
    count                   = local.conditions.merge_policies ? local.total_buckets : 0

    source_policy_documents = [
        data.aws_iam_policy_document.unmerged[count.index].json,
        var.bucket.policy
    ]
}

data "aws_iam_policy_document" "unmerged" {
  #checkov:skip=CKV_AWS_111: "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_108: "Ensure IAM policies does not allow data exfiltration"
    # TODO: fix CHK_AWS_108
  count                     = local.total_buckets


  statement {
    sid                     = "EnableActions"
    effect                  = "Allow"
    actions                 = [ "s3:*" ]
    resources               = count.index == 0 ? (
                              local.source_bucket_arns 
                            ) : [
                              local.destination_bucket_arns[count.index - 1], 
                              local.destination_bucket_path_arns[count.index - 1]
                            ]
                            

    principals {
      type                  =  "AWS"
      identifiers           = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
  }

  statement {
    sid                     = "DenyActions"
    effect                  = "Deny"
    actions                 = [
      "s3:DeleteBucket",
      "s3:PutBucketAcl",
      "s3:PutObjectAcl",
      "s3:PutObjectVersionAcl"
    ]
    resources               = count.index == 0 ? (
                              local.source_bucket_arns 
                            ) : [
                              local.destination_bucket_arns[count.index - 1], 
                              local.destination_bucket_path_arns[count.index - 1]
                            ]

    principals {
      type                  =  "AWS"
      identifiers           = [ "*" ]
    }
  }
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect                  = "Allow"
    actions                 = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]
    resources               = local.source_bucket_arns

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
    resources               = local.source_bucket_arns

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
    resources               = local.destination_bucket_arns
    
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