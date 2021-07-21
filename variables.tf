variable "aws_profiles" {
  type        = map(string)
  description = "AWS env profile for deployment"
}

variable "allowed_envs" {
  type        = list(string)
  description = "List of valid envs allowed for deployment"
  default     = ["dev", "qa", "stage", "prod"]
}

variable "deploy_env" {
  type        = string
  description = "SDLC env for deploying the ecs cluster"
  validation {
    #    condition     = contains(var.allowed_envs, var.deploy_env)
    condition     = contains(["dev", "qa", "stage", "prod"], var.deploy_env)
    error_message = "The deploy_env can only assume either of the values: [dev, qa, stage, prod]."
  }
}

# LC variables
variable "app_name" {
  type        = string
  description = "ECS application name"
}

/*
variable "ec2_ami_id" {
  type        = map(string)
  description = "ec2 ami id"
}
*/
variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "ec2_key_name" {
  type        = string
  description = "EC2 key anme for login to instance"
}

variable "security_groups" {
  type        = map(list(string))
  description = "Security group IDs to associate with infra"
}


# ASG variables
variable "availability_zones" {
  type        = map(list(string))
  description = "List of availability zones for the instances to create in"
}

variable "min_instances" {
  type    = number
  default = 1
}

variable "max_instances" {
  type    = number
  default = 2
}

variable "desired_instances" {
  type    = number
  default = 1
}

variable "policy_full_names" {
  type        = set(string)
  description = "Set of all policy ARN sub part"
}

