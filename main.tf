locals {
  policies = {
  for k, q in var.queues : k => {
    main_policy = jsonencode({
      Version   = "2012-10-17",
      Statement = [
        {
          Effect    = "Allow",
          Principal = { AWS = "*" },
          Action    = [
            "sqs:ChangeMessageVisibility",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes",
            "sqs:GetQueueUrl",
            "sqs:ReceiveMessage",
            "sqs:SendMessage",
            "sqs:PurgeQueue",
          ],
          Resource  = aws_sqs_queue.main[k].arn
        }
      ]
    })
    dlq_policy = jsonencode({
      Version   = "2012-10-17",
      Statement = [
        {
          Effect    = "Allow",
          Principal = { AWS = "*" },
          Action    = [
            "sqs:ChangeMessageVisibility",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes",
            "sqs:GetQueueUrl",
            "sqs:ReceiveMessage",
            "sqs:SendMessage",
            "sqs:PurgeQueue",
          ],
          Resource  = aws_sqs_queue.dlq[k].arn
        }
      ]
    })
  }
  }
  tags = var.tags
}




resource "aws_sqs_queue" "main" {
  for_each = var.queues

  name                       = each.key
  message_retention_seconds  = each.value.main_queue_retention_seconds
  visibility_timeout_seconds = each.value.visibility_timeout_seconds
  receive_wait_time_seconds  = each.value.receive_wait_time_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[each.key].arn
    maxReceiveCount     = each.value.max_receive_count
  })
  tags = local.tags

}

resource "aws_sqs_queue" "dlq" {
  for_each = var.queues

  name                       = "${each.key}-dlq"
  message_retention_seconds  = each.value.dlq_queue_retention_seconds
  visibility_timeout_seconds = each.value.visibility_timeout_seconds

  tags = local.tags

}


resource "aws_sqs_queue_policy" "main_policy" {
  for_each = var.queues

  queue_url = aws_sqs_queue.main[each.key].id
  policy    = local.policies[each.key].main_policy
}


resource "aws_sqs_queue_policy" "dlq_policy" {
  for_each = var.queues

  queue_url = aws_sqs_queue.dlq[each.key].id
  policy    = local.policies[each.key].dlq_policy
}
