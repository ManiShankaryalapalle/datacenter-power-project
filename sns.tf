resource "aws_sns_topic" "load_alerts" {
  name = "load-balancer-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.load_alerts.arn
  protocol  = "email"
  endpoint  = "manishankaryalapalle@gmail.com"
}
