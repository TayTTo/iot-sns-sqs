resource "aws_iam_role" "lambda_func_role" {
  name = "lambda_func_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

data "archive_file" "IoTMetricsEventProcessorFunction" {
  type = "zip"
  source_file = "../src/processor/eventprocessor.js"
  output_path = "./archive/eventprocessor.zip"
}

data "archive_file" "AllFilteredEventConsumerFunction" {
  type = "zip"
  source_file = "../src/consumer/"
  output_path = "./archive/consumer.zip"
}
