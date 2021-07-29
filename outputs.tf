output "ecs_cluster_name" {
  value       = "${var.app_name}-ecs-cluster"
  description = "The ECS cluster created"
}

output "ecs_cluster_arn" {
  value       = module.ecs_cluster.cluster_arn
  description = "ARN of the ecs cluster created"
}

output "alb_endpoint" {
  value       = module.alb.alb_dns
  description = "The ALB DNS name for application access"
}

