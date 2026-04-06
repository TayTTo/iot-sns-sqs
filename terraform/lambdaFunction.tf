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
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

data "archive_file" "IoTMetricsEventProcessorFunction" {
  type        = "zip"
  source_file = "../src/processor/eventprocessor.js"
  output_path = "./archive/eventprocessor.zip"
}

data "archive_file" "AllFilteredEventConsumerFunction" {
  type        = "zip"
  source_dir  = "../src/consumer/"
  output_path = "./archive/consumer.zip"
}

resource "aws_lambda_function" "IOT_metrics_event_processor_function" {
  function_name = "IOT_metrics_event_processor_function"
  role          = aws_iam_role.lambda_func_role.arn
  filename      = data.archive_file.IoTMetricsEventProcessorFunction.output_path
  handler       = "eventprocessor.handler"
  runtime       = "nodejs16.x"
  timeout       = 3
  memory_size   = 128
  environment {
    variables = {
      SNStopic = aws_sns_topic.sns-topic.arn
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_func_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_sqs" {
  role       = aws_iam_role.lambda_func_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_iam_role" "iot_rule_role" {
  name = "IoTRuleToSNSRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "iot.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "iot_sns_policy" {
  name = "IoTSNSPublishPolicy"
  role = aws_iam_role.iot_rule_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.sns-topic.arn
      }
    ]
  })
}

resource "aws_lambda_function" "consumer_function" {
  function_name = "consumer_function"
  role          = aws_iam_role.lambda_func_role.arn
  filename      = data.archive_file.AllFilteredEventConsumerFunction.output_path
  handler       = "allfilteredeventconsumer.handler"
  runtime       = "nodejs16.x"
  timeout       = 3
  memory_size   = 128
  environment {
    variables = {
      DatabaseTable = aws_dynamodb_table.IOT_DB.arn
    }
  }
}

resource "aws_iot_topic_rule" "iot_sensor_thing" {
  name        = "IotSensorthing"
  enabled     = true
  sql         = "SELECT * FROM 'device/iotsensors'"
  sql_version = "2016-03-23"
  lambda {
    function_arn = aws_lambda_function.IOT_metrics_event_processor_function.arn
  }
  sns {
    message_format = "JSON"
    role_arn       = aws_iam_role.iot_rule_role.arn
    target_arn     = aws_iot_thing.IotSensorThing.arn
  }
}

resource "aws_lambda_event_source_mapping" "map_sqs_queue" {
  event_source_arn = aws_sqs_queue.sqs_queue["metric-sqs-queue"].arn
  function_name    = aws_lambda_function.IOT_metrics_event_processor_function.arn
  batch_size       = 10

  scaling_config {
    maximum_concurrency = 100
  }
}
