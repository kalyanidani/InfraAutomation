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
  name                      = "${var.app_name}-asg"
  launch_configuration      = aws_launch_configuration.app_lc.id
  min_size                  = var.min_instances
  max_size                  = var.max_instances
  desired_capacity          = var.desired_instances
  health_check_grace_period = 300
  health_check_type         = "ELB"

  availability_zones = lookup(var.availability_zones, var.deploy_env)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_capacity_provider" "app_ecs_cp" {
  name = "${var.app_name}-ecs-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.app_asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 10
    }
  }
}

resource "aws_kms_key" "app_kms_key" {
  description             = "Kms key for app ecs cluster"
  deletion_window_in_days = 15
}

resource "aws_cloudwatch_log_group" "app_log_group" {
  name = "${var.app_name}-log-group"
  retention_in_days = 14
  kms_key_id = aws_kms_key.app_kms_key.id
}

resource "aws_ecs_cluster" "app_ecs_cluster" {
  name = "${var.app_name}-ecs-cluster"

  capacity_providers = aws_ecs_capacity_provider.app_ecs_cp.id

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.app_kms_key.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.app_log_group.name
      }
    }
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



