variable "region" {
  type = string
  default = "ap-southeast-1"
}

variable "queue_names" {
  type = list(string)
  default = ["metric-sqs-queue", "temprature-sqs-queue", "humidity-sqs-queue"]
}

