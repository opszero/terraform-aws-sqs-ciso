output "sqs_queue_arn" {
  value = [for queue_key, queue_instance in aws_sqs_queue.main : queue_instance.arn]
}
