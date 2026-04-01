resource "aws_sns_topic" "sns-topic" {
  name = "sns-topic"
}

resource "aws_sns_topic_policy" "sns-topic-policy" {
  arn = aws_sns_topic.sns-topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.sns-topic.arn,
    ]

    sid = "__default_statement_ID"
  }
}

resource "aws_sns_topic_subscription" "sqs_subcribtion" {
  for_each = aws_sqs_queue.sqs_queue
  topic_arn = aws_sns_topic.sns-topic.arn
  protocol  = "sqs"
  endpoint  = each.value.arn
}
