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
    }
  }
  tags = var.tags
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

}


resource "aws_sqs_queue" "main" {
  for_each = var.queues

  name                       = each.key
  message_retention_seconds  = each.value.main_queue_retention_seconds
  visibility_timeout_seconds = each.value.visibility_timeout_seconds
  receive_wait_time_seconds  = each.value.receive_wait_time_seconds

  redrive_policy = var.enable_redrive_policy ? jsonencode({
    deadLetterTargetArn = each.value.redrive_policy.deadLetterTargetArn
    maxReceiveCount     = each.value.redrive_policy.maxReceiveCount
  }) : null
  tags = local.tags

}

resource "aws_sqs_queue_policy" "main_policy" {
  for_each = var.queues

  queue_url = aws_sqs_queue.main[each.key].id
  policy    = var.sqs_queue_policy == null ? local.policies[each.key].main_policy : var.sqs_queue_policy
}