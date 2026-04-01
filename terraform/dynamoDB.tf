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
