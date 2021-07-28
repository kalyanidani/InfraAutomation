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



