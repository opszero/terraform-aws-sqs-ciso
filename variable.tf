variable "queues" {
  description = "Map of queue names and their properties"
  type = map(object({
    main_queue_retention_seconds : string
    dlq_queue_retention_seconds : string
    visibility_timeout_seconds : string
    receive_wait_time_seconds : string
    max_receive_count : number
  }))
}

variable "tags" {}