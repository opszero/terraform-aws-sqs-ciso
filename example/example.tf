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
    },

    "queues-2" = {
      main_queue_retention_seconds = "1209600"
      dlq_queue_retention_seconds  = "1209600"
      visibility_timeout_seconds   = "60"
      receive_wait_time_seconds    = "10"
      max_receive_count            = 5
    }
    # Add other queues here
  }
}
