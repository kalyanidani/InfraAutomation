resource "aws_lb" "this" {
  name               = var.alb_name
  internal           = var.alb_internal
  load_balancer_type = var.alb_type
  security_groups    = var.alb_security_groups
  subnets            = var.alb_subnet_ids

  enable_deletion_protection = var.alb_delete_protection

  tags = var.tags
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.alb_listener_port
  protocol          = var.alb_listener_protocol

  default_action {
    type             = "fixed-response"
    fixed_response {
	content_type = "text/plain"
	message_body = var.alb_listener_default_response
	status_code = 200
    }
  }
}

resource "aws_lb_target_group" "this" {
  name        = var.tg_name
  port        = var.tg_port
  protocol    = var.tg_protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = aws_lb_listener.this.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    path_pattern {
      values = var.lb_path_pattern_list
    }
  }
}

/*
resource "aws_lb_listener" "secure" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.alb_listener_port
  protocol          = var.alb_listener_protocol
  ssl_policy        = var.alb_security_policy
  certificate_arn   = var.alb_secure_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
*/


