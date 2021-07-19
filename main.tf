# --------- provider and backend configuration -----------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.50.0"
    }
  }

  backend "s3" {

  }

}

provider "aws" {
  region  = "us-east-1"
  profile = lookup(var.aws_profiles, var.deploy_env, "default")
}


# ------------- resources -------------------

resource "aws_launch_configuration" "app_lc" {
  name          = "${var.app_name}-lc"
  image_id      = lookup(var.ec2_ami_id, var.deploy_env)
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_key_name

  security_groups = lookup(var.security_groups, var.deploy_env)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                 = "${var.app_name}-asg"
  launch_configuration = aws_launch_configuration.app_lc.id
  min_size             = var.min_instances
  max_size             = var.max_instances
  desired_capacity     = var.desired_instances
  health_check_grace_period = 300
  health_check_type         = "ELB"  

  availability_zones = lookup(var.availability_zones, var.deploy_env)

  lifecycle {
    create_before_destroy = true
  }
}




/*
resource "aws_ecs_cluster" "app_ecs_cluster" {
  name = "${var.app_name}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
*/



