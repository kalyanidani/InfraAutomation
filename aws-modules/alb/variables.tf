variable "alb_name" {
    type = string
}

variable "alb_internal" {
    type = bool
    description = "Determines if the ALB is internal or internet-facing"
    default = false
}

variable "alb_type" {
    type = string
    default = "application"
}

variable "alb_security_groups" {
    type = list(string)
}

variable "alb_subnet_ids" {
    type = list(string)
}

variable "alb_delete_protection" {
    type = bool
    default = false
}

variable "tags" {
    type = map(string)
}

variable "alb_listener_port" {
    type = number
    default = 80
}

variable "alb_listener_protocol" {
    type = string
    default = "HTTP"
}

variable "alb_listener_default_response" {
    type = string
    description = "Fixed response (default) string for listener"
}

variable "tg_name" {
    type = string
}

variable "tg_port" {
    type = number
    default = 80
}

variable "tg_protocol" {
    type = string
    default = "HTTP"
}

variable "target_type" {
    type = string
    default ="ip"
}

variable "vpc_id" {
    type = string
}


