variable "app_name" {
  type        = string
  description = "Application short name"
}

variable "deploy_env" {
  type        = string
  description = "SDLC env for deploying the ecs cluster"
  validation {
    condition     = contains(["dev", "qa", "stage", "prod"], var.deploy_env)
    error_message = "The deploy_env can only assume either of the values: [dev, qa, stage, prod]."
  }
}

variable "vpc_id" {
  type = map(string)
}

variable "aws_profiles" {
  type        = map(string)
  description = "AWS env profile for deployment"
}

variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "ec2_key_name" {
  type        = string
  description = "EC2 key anme for login to instance"
}

variable "availability_zones" {
  type        = map(list(string))
  description = "List of availability zones needed for asg"
}

variable "container_def_file_path" {
  type = string
  description = "Path of the container definition json file"  
}

