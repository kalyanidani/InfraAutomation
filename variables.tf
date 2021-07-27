

variable "app_name" {
    type = string
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

aws_profiles = {
  "dev" = "default"
  "qa"  = "qaprofile"
}