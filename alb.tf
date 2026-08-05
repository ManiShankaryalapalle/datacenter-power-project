resource "aws_lb" "web_alb" {
  name               = "datacenter-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = ["subnet-076eca543b1164872", "subnet-0911b5bb7225b7ab1"]
}

resource "aws_lb_target_group" "web_tg" {
  name     = "datacenter-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-07729e257c9e86ab5"

  health_check {
    path                = "/"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "web_attach" {
  count            = 3
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.machine[count.index].id
  port             = 80
}
