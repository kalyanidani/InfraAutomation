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

# ------------- get ecs-optimized-ec2 ami --------------

data "aws_ami" "ecs_optimized_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

module "iam_role" {
  source = "./aws-modules/iam-roles"

  role_name = "${var.app_name}-role"
  tags = local.common_tags
  create_instance_profile = true
}

module "iam_role_attach" {
  source = "./aws-modules/iam-roles-attachment"

  for_each = var.policy_full_names
  role_id = iam_role.role_id
  policy_arn = each.key  
}

# ------------- resources -------------------

resource "aws_launch_configuration" "app_lc" {
  name          = "${var.app_name}-lc"
#  image_id      = lookup(var.ec2_ami_id, var.deploy_env)
  image_id    = data.aws_ami.ecs_optimized_ami.id
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_key_name
  iam_instance_profile = var.iam_instance_profile

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

resource "aws_iam_service_linked_role" "app_ecs_cp_role" {
  aws_service_name = "ecs.amazonaws.com"
}

resource "aws_ecs_capacity_provider" "app_ecs_cp" {
  name       = "${var.app_name}-ecs-cp"
  depends_on = [aws_iam_service_linked_role.app_ecs_cp_role]

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.app_asg.arn

    #    managed_scaling {
    #      maximum_scaling_step_size = 1000
    #      minimum_scaling_step_size = 1
    #      status                    = "ENABLED"
    #      target_capacity           = 10
    #    }
  }
}

resource "aws_kms_key" "app_kms_key" {
  description             = "Kms key for app ecs cluster"
  deletion_window_in_days = 15
}

resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "${var.app_name}-log-group"
  retention_in_days = 14
}

resource "aws_ecs_cluster" "app_ecs_cluster" {
  name = "${var.app_name}-ecs-cluster"

  capacity_providers = ["${aws_ecs_capacity_provider.app_ecs_cp.name}"]

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

resource "aws_ecs_task_definition" "app_ecs_task_defn" {
  family                = "service"
  container_definitions = file("ecs/app-task-definition.json")

  # execution_role_arn = 
  # task_role_arn = 
  network_mode = "bridge"

}

/*
resource "aws_ecs_service" "app_service" {
  name            = "${var.app_name}-svc"
  cluster         = aws_ecs_cluster.app_ecs_cluster.id
  task_definition = aws_ecs_task_definition.app_ecs_task_defn.arn
  desired_count   = 1
  #iam_role        = aws_iam_role.foo.arn
  #depends_on      = [aws_iam_role_policy.foo]

  load_balancer {
    target_group_arn = aws_lb_target_group.foo.arn
    container_name   = "my-app"
    container_port   = 8000
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}

*/

