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

locals {
  common_tags = {
    environment = var.deploy_env
    app_stack   = var.app_name
  }
}
#-------------- data sources ----------------
data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

#-------------- ecs cluster create ----------------
module "iam_ecs_role" {
  source                  = "./aws-modules/iam-ecs-role"
  role_name               = "${var.app_name}-ecsrole"
  create_instance_profile = true
  tags                    = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ec2_service_role" {
  role       = module.iam_ecs_role.role_id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

module "launch_config" {
  source               = "./aws-modules/launch-config"
  lc_name              = "${var.app_name}-lc"
  image_id             = data.aws_ssm_parameter.ecs_ami.value
  ec2_instance_type    = var.ec2_instance_type
  ec2_key_name         = var.ec2_key_name
  iam_instance_profile = module.iam_ecs_role.instance_profile_id[0]
  #iam_instance_profile = "${var.app_name}-ecsrole-instance-profile"
  security_groups = [module.container_instance_security_group.security_group_id]
  ec2_user_data   = "${path.module}/${var.ec2_user_data_file_path}"

  ecs_cluster_name = "${var.app_name}-ecs-cluster"
  depends_on       = [module.ecs_cluster]
}

module "asg" {
  source             = "./aws-modules/asg"
  asg_name           = "${var.app_name}-asg"
  lc_id              = module.launch_config.lc_id
  min_instances      = 1
  max_instances      = 1
  desired_instances  = 1
  availability_zones = lookup(var.availability_zones, var.deploy_env)
}

module "ecs_cluster" {
  source       = "./aws-modules/ecs-cluster"
  cluster_name = "${var.app_name}-ecs-cluster"
}

module "alb_security_group" {
  source              = "./aws-modules/security-group"
  security_group_name = "${var.app_name}-lb-sg"
  security_group_desc = "SG to allow internet incoming traffic at port 80 for ALB"
  sec_vpc_id          = lookup(var.vpc_id, var.deploy_env)
  tags                = local.common_tags
}

resource "aws_security_group_rule" "alb_sg_ingress" {
  type              = "ingress"
  description       = "allow internet connection to port 80"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.alb_security_group.security_group_id
}

resource "aws_security_group_rule" "alb_sg_egress" {
  type              = "egress"
  description       = "allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.alb_security_group.security_group_id
}

module "container_instance_security_group" {
  source              = "./aws-modules/security-group"
  security_group_name = "${var.app_name}-ci-sg"
  security_group_desc = "SG to allow traffic from ALB to container instances"
  sec_vpc_id          = lookup(var.vpc_id, var.deploy_env)
  tags                = local.common_tags
}

resource "aws_security_group_rule" "ci_sg_ingress" {
  type                     = "ingress"
  from_port                = 35000
  to_port                  = 65000
  protocol                 = "TCP"
  source_security_group_id = module.alb_security_group.security_group_id
  security_group_id        = module.container_instance_security_group.security_group_id
}

/* To do: Have single egress rule resource included in module,
and call the same module for both alb_sg_egress and ci_sg_egress
*/

resource "aws_security_group_rule" "ci_sg_egress" {
  type              = "egress"
  description       = "allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.container_instance_security_group.security_group_id
}

module "task_definition" {
  source               = "./aws-modules/task-definition"
  task_definition_name = "${var.app_name}-taskdefinition"
  container_def_json   = "${path.module}/${var.container_def_file_path}"
  tags                 = local.common_tags
}

module "alb" {
  source              = "./aws-modules/alb"
  alb_name            = "${var.app_name}-alb"
  alb_security_groups = [module.alb_security_group.security_group_id]
  alb_subnet_ids      = var.alb_subnet_ids
  tags                = local.common_tags

  alb_listener_port     = var.alb_listener_port
  alb_listener_protocol = var.alb_listener_protocol

  alb_listener_default_response = var.alb_listener_default_response

  tg_name = "${var.app_name}-tg"
  vpc_id  = lookup(var.vpc_id, var.deploy_env)
}


module "ecs_service" {

  source         = "./aws-modules/ecs-service"
  service_name   = "${var.app_name}-ecs-service"
  ecs_cluster_id = module.ecs_cluster.cluster_id
  task_def_arn   = module.task_definition.task_definition_arn
  des_count      = var.tasks_desired_count
  iam_role_arn   = var.ecs_iam_role_arn

  target_group_arn = module.alb.alb_tg_arn
  container_name   = var.app_name
  container_port   = var.app_port

  tags = local.common_tags
}
