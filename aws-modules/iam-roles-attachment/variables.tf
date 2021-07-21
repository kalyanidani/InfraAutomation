variable "role_id" {
    type = string
    description = "Role id for policy attachment"
}

variable "policy_arn" { 
    type = string
    description = "Policy arn for attachment to role"
}