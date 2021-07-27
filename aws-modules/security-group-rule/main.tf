variable "rule_type" {
    type = string
    description = "Security group type, either ingress or egress"
    validation {
        condition = var.rule_type == "ingress" || var.rule_type == "egress"
        error_message = "The rule_type can either be [ingress] or [egress]"
    }
}

variable "sec_rule_description" {
    type = string
    description = "Description for security group rule"
    default = "Security group rule"
}

variable "from_port" {
    type = number
    description = "Source port number"
}

variable "to_port" {
    type = number
    description = "Destination port number"
}

variable "rule_protocol" {
    type = string
    description = "Protocol"  
}

variable "security_group_id" {
    type = string
    description = "Security group id to attach the rule"  
}

resource "aws_security_group_rule" "this" {
  type              = var.rule_type
  description       = var.sec_rule_description
  from_port         = var.from_port
  to_port           = var.to_port
  protocol          = var.rule_protocol  
  security_group_id = var.security_group_id
}

