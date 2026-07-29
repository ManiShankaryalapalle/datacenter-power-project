data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "heat_simulator_role" {
  name               = "heat-simulator-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem"
    ]
    resources = [aws_dynamodb_table.machine_metrics.arn]
  }
statement {
    effect = "Allow"
    actions = [
      "dynamodb:Query"
    ]
    resources = [aws_dynamodb_table.machine_metrics.arn]
  }

}

resource "aws_iam_role_policy" "heat_simulator_policy" {
  name   = "heat-simulator-lambda-policy"
  role   = aws_iam_role.heat_simulator_role.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}
