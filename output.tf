output "sqs_queue_details" {
  value = {
    for queue_name, queue_resource in aws_sqs_queue.main :
    queue_name => {
      arn   = queue_resource.arn
      name  = queue_resource.name
      message_retention_seconds  = queue_resource.message_retention_seconds
      visibility_timeout_seconds = queue_resource.visibility_timeout_seconds
      receive_wait_time_seconds  = queue_resource.receive_wait_time_seconds
      redrive_policy             = jsondecode(queue_resource.redrive_policy)
      tags                       = queue_resource.tags
    }
  }
  description = "A map of SQS queue names to their details."
}

output "sqs_dlq_details" {
  value = {
    for queue_name, queue_resource in aws_sqs_queue.dlq :
    queue_name => {
      arn                        = queue_resource.arn
      name                       = queue_resource.name
      message_retention_seconds  = queue_resource.message_retention_seconds
      visibility_timeout_seconds = queue_resource.visibility_timeout_seconds
      tags                       = queue_resource.tags
    }
  }
  description = "A map of SQS DLQ names to their details."
}