variable "asg_name" {
    type = string
    description = "ASG name"  
}

variable "lc_id" {
  type = string
  description = "Launch configuration ID"
}

variable "min_instances" {
  type = number
}

variable "max_instances" {
  type = number
}

variable "desired_instances" {
  type = number
}

variable "availability_zones" {
    type = list(string)  
}

variable "tags" {
  type = map(string)
}
