variable "cluster_name" {
    type = string
    description = "ECS Cluster name"
}

variable "enable_container_insights" {
    type = string
    description = "Condition to enable or disable container insights"
    default = "enabled"
}

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  setting {
      name = "containerInsights"
      value = var.enable_container_insights
  } 
}

output "cluster_arn" {
    description = "ECS Cluster ARN"
    value = aws_ecs_cluster.this.arn
}

output "cluster_id" {
    description = "ECS Cluster ID"
    value = aws_ecs_cluster.this.id  
}
