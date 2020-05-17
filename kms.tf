data "aws_iam_policy_document" "simple-artifacts-kms-policy" {
  policy_id = "key-default-1"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms:*",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_kms_key" "simple-artifacts" {
  description = "kms key for life universe and everything"
  policy      = data.aws_iam_policy_document.simple-artifacts-kms-policy.json
}

resource "aws_kms_alias" "simple-artifacts" {
  name          = "alias/simple-artifacts"
  target_key_id = aws_kms_key.simple-artifacts.key_id
}


