variable "task_definition_name" {
    type = string
    description = "Unique name for task identification"
}

variable "container_def_json" {
  type = string
  description = "Complete json file path containing task definition"
}

/*
variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}
*/

variable "network_mode" {
  type = string
  default = "bridge"
}

variable "required_compatibilities" {
    type = set(string)
    default = ["EC2"]  
}

variable "tags" {
    type = map(string) 
}