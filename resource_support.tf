resource "aws_iam_policy" "this" {
    name                        = "${var.bucket.name}-s3-replication-policy"
    policy                      = data.aws_iam_policy_document.replication.json
}

resource "aws_iam_role_policy_attachment" "this" {
    role                        = var.replication_role.name
    policy_arn                  = aws_iam_policy.this.arn
}

resource "aws_sns_topic" "this" {
  kms_master_key_id             = local.encryption_configuration.alias_arn
  name                          = local.event_notification_id
  policy                        = data.aws_iam_policy_document.notification.json
}