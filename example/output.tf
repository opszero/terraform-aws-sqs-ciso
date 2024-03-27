output "sqs_main" {
  value = module.sqs_queues.sqs_queue_details
}

output "sqs_dlq" {
  value = module.sqs_queues.sqs_dlq_details
}