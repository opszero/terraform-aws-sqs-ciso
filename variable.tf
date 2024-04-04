variable "queues" {
  description = "Map of queue names and their properties"
  type        = any
  default     = {}
}


variable "tags" {}

#variable "redrive_policy" {
#  type = map(any)
#  default = {}
#}

variable "redrive_policy" {
  type        = string
  default     = ""
  sensitive   = true
  description = "The JSON policy to set up the Dead Letter Queue, see AWS docs. Note: when specifying maxReceiveCount, you must specify it as an integer (5), and not a string (\"5\")."
}

variable "redrive_policies" {
  description = "Map of redrive policies for each queue"
  type = map(object({
    deadLetterTargetArn = string
    maxReceiveCount     = number
  }))
  default = {
    policy1 = {
      deadLetterTargetArn = ""
      maxReceiveCount     = null
    }
  }
}

variable "enable_redrive_policy" {
  type    = bool
  default = false # Set this to true if you want to enable the redrive policy by default
}

variable "sqs_queue_policy" {
  type    = any
  default = null
}