locals {
  policies = {
    for k, q in var.queues : k => {
      main_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
          {
            Effect    = "Allow",
            Principal = { AWS = "*" },
            Action = [
              "sqs:ChangeMessageVisibility",
              "sqs:DeleteMessage",
              "sqs:GetQueueAttributes",
              "sqs:GetQueueUrl",
              "sqs:ReceiveMessage",
              "sqs:SendMessage",
              "sqs:PurgeQueue",
            ],
            Resource = aws_sqs_queue.main[k].arn
          }
        ]
      })
      dlq_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
          {
            Effect    = "Allow",
            Principal = { AWS = "*" },
            Action = [
              "sqs:ChangeMessageVisibility",
              "sqs:DeleteMessage",
              "sqs:GetQueueAttributes",
              "sqs:GetQueueUrl",
              "sqs:ReceiveMessage",
              "sqs:SendMessage",
              "sqs:PurgeQueue",
            ],
            Resource = aws_sqs_queue.dlq[k].arn
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
  message_retention_seconds  = try(each.value.message_retention_seconds, 1209600)
  visibility_timeout_seconds = try(each.value.visibility_timeout_seconds, 60)
  receive_wait_time_seconds  = try(each.value.receive_wait_time_seconds, 10)
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[each.key].arn
    maxReceiveCount     = try(each.value.max_receive_count, 5)
  })
  tags = local.tags

}

resource "aws_sqs_queue" "dlq" {
  for_each = var.queues

  name                       = "${each.key}-dlq"
  message_retention_seconds  = try(each.value.message_retention_seconds_dlq, 1209600)
  visibility_timeout_seconds = try(each.value.visibility_timeout_seconds, 60)

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




resource "aws_cloudwatch_metric_alarm" "oldest_message_alarm_main" {
  for_each = var.queues

  alarm_name          = "${each.key}-oldest-message-alarm"
  comparison_operator = try(each.value.cloudwatch_comparison_operator, "GreaterThanThreshold")
  evaluation_periods  = try(each.value.evaluation_periods, 1)
  metric_name         = try(each.value.cloudwatch_metric_name, "ApproximateAgeOfOldestMessage")
  namespace           = try(each.value.cloudwatch_namespace, "AWS/SQS")
  period              = try(each.value.cloudwatch_period, 300)
  statistic           = try(each.value.cloudwatch_statistic, "Maximum")
  threshold           = try(each.value.cloudwatch_threshold, 300)
  alarm_description   = try(each.value.cloudwatch_alarm_description, "Alarm when the oldest message is older than 5 minutes")
  actions_enabled     = try(each.value.cloudwatch_actions_enabled, true)

  dimensions = {
    QueueName = each.key
  }
  tags = var.tags
}


resource "aws_cloudwatch_metric_alarm" "oldest_message_alarm_dlq" {
  for_each = var.queues

  alarm_name          = "${each.key}-oldest-message-alarm-dlq"
  comparison_operator = try(each.value.cloudwatch_comparison_operator, "GreaterThanThreshold")
  evaluation_periods  = try(each.value.evaluation_periods, 1)
  metric_name         = try(each.value.cloudwatch_metric_name, "ApproximateAgeOfOldestMessage")
  namespace           = try(each.value.cloudwatch_namespace, "AWS/SQS")
  period              = try(each.value.cloudwatch_period, 300)
  statistic           = try(each.value.cloudwatch_statistic, "Maximum")
  threshold           = try(each.value.cloudwatch_threshold, 300)
  alarm_description   = try(each.value.cloudwatch_alarm_description, "Alarm when the oldest message is older than 5 minutes")
  actions_enabled     = try(each.value.cloudwatch_actions_enabled, true)


  dimensions = {
    QueueName = "${each.key}-dlq"
  }

  tags = var.tags
}

