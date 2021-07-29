output "alb_id" {
    value = aws_lb.this.id  
}

output "alb_arn" {
    value = aws_lb.this.arn  
}

output "alb_listener_id" {
    value = aws_lb_listener.this.id  
}

output "alb_listener_arn" {
    value = aws_lb_listener.this.arn
}

output "alb_tg_id" {
    value = aws_lb_target_group.this.id   
}

output "alb_tg_arn" {
    value = aws_lb_target_group.this.arn
}

output "alb_dns" {
    value = aws_lb.this.dns_name
}