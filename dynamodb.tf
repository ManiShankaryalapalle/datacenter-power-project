resource "aws_dynamodb_table" "machine_metrics" {
  name         = "machine-metrics"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "instance_id"
  range_key    = "timestamp"

  attribute {
    name = "instance_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }
}
