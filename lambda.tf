resource "aws_lambda_function" "heat_simulator" {
  function_name = "heat-simulator"
  role          = aws_iam_role.heat_simulator_role.arn
  handler       = "heat_simulator.lambda_handler"
  runtime       = "python3.12"

  filename         = "lambda/heat_simulator.zip"
  source_code_hash = filebase64sha256("lambda/heat_simulator.zip")

  timeout = 30
}
resource "aws_cloudwatch_event_rule" "heat_simulator_schedule" {
  name                = "heat-simulator-schedule"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "heat_simulator_target" {
  rule = aws_cloudwatch_event_rule.heat_simulator_schedule.name
  arn  = aws_lambda_function.heat_simulator.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.heat_simulator.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.heat_simulator_schedule.arn
}
