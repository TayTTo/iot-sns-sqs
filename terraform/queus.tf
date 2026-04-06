resource "aws_sqs_queue" "sqs_dl_queue" {
  for_each = toset(var.queue_names)
  name = "${each.value}-dlq"
}

resource "aws_sqs_queue" "sqs_queue" {
  for_each = toset(var.queue_names)
  name     = each.value
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_dl_queue[each.key].arn
    maxReceiveCount     = 4
  })
}

# SQS Queue Policy to allow SNS delivery
resource "aws_sqs_queue_policy" "sqs_queue_policy" {
  for_each  = toset(var.queue_names)
  queue_url = aws_sqs_queue.sqs_queue[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSNSDelivery"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.sqs_queue[each.key].arn
        Condition = {
          StringEquals = {
            "aws:SourceArn" = aws_sns_topic.sns-topic.arn
          }
        }
      }
    ]
  })
}
