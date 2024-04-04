provider "aws" {
  region = "ap-south-1"
}


module "sqs_queues" {
  source = "./../"
  tags = {
    Env = "Prod"
  }

  queues = {
    "queues-1" = {
      main_queue_retention_seconds = "1209600"
      dlq_queue_retention_seconds  = "1209600"
      visibility_timeout_seconds   = "60"
      receive_wait_time_seconds    = "10"
      max_receive_count            = 5
      ##cloudwatch_metric_alarm
      cloudwatch_comparison_operator = "GreaterThanThreshold"
      evaluation_periods             = "1"
      cloudwatch_metric_name         = "ApproximateAgeOfOldestMessage"
      cloudwatch_namespace           = "AWS/SQS"
      cloudwatch_statistic           = "Maximum"
      cloudwatch_threshold           = 300
      cloudwatch_alarm_description   = "Alarm when the oldest message is older than 5 minutes"
      cloudwatch_actions_enabled     = true

    },

    "queues-2" = {
      main_queue_retention_seconds = "1209600"
      dlq_queue_retention_seconds  = "1209600"
      visibility_timeout_seconds   = "60"
      receive_wait_time_seconds    = "10"
      max_receive_count            = 5

      ##cloudwatch_metric_alarm
      cloudwatch_comparison_operator = "GreaterThanThreshold"
      evaluation_periods             = "1"
      cloudwatch_metric_name         = "ApproximateAgeOfOldestMessage"
      cloudwatch_namespace           = "AWS/SQS"
      cloudwatch_statistic           = "Maximum"
      cloudwatch_threshold           = 300
      cloudwatch_alarm_description   = "Alarm when the oldest message is older than 5 minutes"
      cloudwatch_actions_enabled     = true

    }
    # Add other queues here
  }
}