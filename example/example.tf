provider "aws" {
  region = "us-east-2"
}

module "sqs_queues" {
  source = "./../"
  tags = {
    Env = "Prod"
  }


  queues = {
    "queues-1" = {
      #main
      message_retention_seconds  = 1209600
      visibility_timeout_seconds = 60
      receive_wait_time_seconds  = 10

      #dlq
      message_retention_seconds_dlq = 1209600
      visibility_timeout_seconds    = 60
      ##cloudwatch_metric_alarm
      evaluation_periods           = 1
      cloudwatch_threshold         = 300
      cloudwatch_alarm_description = "Alarm when the oldest message is older than 5 minutes"
      cloudwatch_actions_enabled   = true

    },

    "queues-2" = {
      message_retention_seconds  = 1209600
      visibility_timeout_seconds = 60
      receive_wait_time_seconds  = 10

      #dlq
      message_retention_seconds_dlq = 1209600
      visibility_timeout_seconds    = 60

      ##cloudwatch_metric_alarm
      evaluation_periods           = 1
      cloudwatch_threshold         = 300
      cloudwatch_alarm_description = "Alarm when the oldest message is older than 5 minutes"
      cloudwatch_actions_enabled   = true

    }
    # Add other queues here
  }
}
