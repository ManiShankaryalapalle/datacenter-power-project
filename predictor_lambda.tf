resource "aws_lambda_function" "predictor" {
  function_name = "load-predictor"
  role          = aws_iam_role.heat_simulator_role.arn
  handler       = "predictor.lambda_handler"
  runtime       = "python3.12"

  filename         = "lambda/predictor.zip"
  source_code_hash = filebase64sha256("lambda/predictor.zip")

  timeout = 30
}

resource "aws_cloudwatch_event_rule" "predictor_schedule" {
  name                = "predictor-schedule"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "predictor_target" {
  rule = aws_cloudwatch_event_rule.predictor_schedule.name
  arn  = aws_lambda_function.predictor.arn
}

resource "aws_lambda_permission" "allow_eventbridge_predictor" {
  statement_id  = "AllowEventBridgeInvokePredictor"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.predictor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.predictor_schedule.arn
}
