variable "security_group_name" {
    type = string
    description = "Security group name"
}

variable "security_group_desc" {
    type = string
    description = "Description for security group"
}

variable "sec_vpc_id" {
    type = string
    description = "VPC id for security group"
}

variable "tags" {
    type = map(string)
    description = "List of all tags to apply"
  
}

resource "aws_security_group" "this" {
    name = var.security_group_name
    description = var.security_group_desc
    vpc_id = var.sec_vpc_id

    tags = var.tags  
}

output "security_group_id" {
    value = aws_security_group.this.id
    description = "Security group ID"
}

