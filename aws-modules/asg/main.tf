resource "aws_autoscaling_group" "this" {
  name                      = var.asg_name
  launch_configuration      = var.lc_id
  min_size                  = var.min_instances
  max_size                  = var.max_instances
  desired_capacity          = var.desired_instances
  health_check_grace_period = 300
  health_check_type         = "EC2"

#  availability_zones = lookup(var.availability_zones, var.deploy_env)
    availability_zones = var.availability_zones

  lifecycle {
    create_before_destroy = true
  }

}
