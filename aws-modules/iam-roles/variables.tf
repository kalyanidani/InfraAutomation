variable "role_name" {
    type = string
    description = "Role name"
}

variable "tags" {
    type = map(string)
    description = "Map containing all the tag elements (key valuye pair)"
}

variable "create_instance_profile" {
    type = bool
    description = "Boolean flag to create instance profile or not"
    default = false
}