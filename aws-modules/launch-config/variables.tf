variable "lc_name" {
    type = string
    description = "LC name"
}

variable "image_id" {
    type = string
    description = "EC2 ami image id"
}

variable "ec2_instance_type" {
    type = string
    description = "EC2 Instance type, ex t2.large, m5.small"
}

variable "ec2_key_name" {
    type = string
    description = "Key pair name for ec2 ssh authentication"
}

variable "iam_instance_profile" {
    type = string
    description = "IAM instance porofile id"
}

variable "security_groups" {
    type = list(string)
    description = "List of security groups to attach to ec2"
}

variable "ec2_user_data" {
    type = string
    description = "File path containing user_data ec2 instantiation" 
}