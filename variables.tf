variable "aws_profiles" {
    type = map(string)
    description = AWS env profile for deployment
}

variable allowed_envs {
    type = list(string)
    description = List of valid envs allowed for deployment
    default = ["dev", "qa", "stage", "prod"]
}

variable "deploy_env" {
    type = string
    description = SDLC env for deploying the ecs cluster
    validation {
        condition = contains (var.allowed_envs, var.deploy_env)
        error_message = "deploy_env can only assume either of the values: ${var.allowed_envs} "
    }
}

variable "app_name" {
    type = string
    description = ECS application name
}

variable "ec2_instance_type" {
    type = string
    description = EC2 instance type
}

variable "ec2_key_name" {
    type = string
    description = EC2 key anme for login to instance
}

variable "security_groups" {
    type = list(string)
    description = Security group IDs to associate with infra
}
