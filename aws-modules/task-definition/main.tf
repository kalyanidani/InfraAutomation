resource "aws_ecs_task_definition" "this" {
    family = var.task_definition_name

    container_definitions = file(var.container_def_json)

#    execution_role_arn = var.execution_role_arn
#    task_role_arn = var.task_role_arn
    network_mode = var.network_mode

    requires_compatibilities = var.required_compatibilities

    tags = var.tags

}
