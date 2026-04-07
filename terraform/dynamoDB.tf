resource "aws_dynamodb_table" "IOT_DB" {
  name           = "IOT_DB"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }

  tags = {
    Name        = "IOT_DB"
    Environment = "production"
  }
}

resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "LambdaDynamoDBPolicy"
  role = aws_iam_role.lambda_func_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.IOT_DB.arn
      }
    ]
  })
}
