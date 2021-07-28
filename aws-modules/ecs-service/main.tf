variable "service_name" { type = string }
variable "ecs_cluster_id" { type = string }
variable "task_def_arn" { type = string }
variable "des_count" { type = number }
variable "iam_role_arn" { type = string }

variable "target_group_arn" { type = string }
variable "container_name" { type = number }
variable "container_port" { type = string }
variable "tags" { type = map(string) }

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.ecs_cluster_id
  task_definition = var.task_def_arn
  desired_count   = var.des_count
  iam_role        = var.iam_role_arn

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  tags = var.tags
}

output "ecs_service_id_arn" {
    value = aws_ecs_service.this.id
}