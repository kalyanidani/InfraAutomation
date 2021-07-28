resource "aws_launch_configuration" "this" {
  name                  = var.lc_name
  image_id             = var.image_id
  instance_type        = var.ec2_instance_type
  key_name             = var.ec2_key_name
  iam_instance_profile = var.iam_instance_profile
  security_groups       = var.security_groups

  user_data = templatefile(var.ec2_user_data, { ecs_cluster = var.ecs_cluster_name }  )

  lifecycle {
    create_before_destroy = true
  }
}
