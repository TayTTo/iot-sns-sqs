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

