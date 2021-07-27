output "task_definition_arn" {
    value = aws_ecs_task_definition.this.arn
    description = "ARN of task definition"
}

output "task_definition_revision" {
    value = aws_ecs_task_definition.this.revision
    description = "Revision # for task definition used"
}