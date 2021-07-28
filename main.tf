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
  source            = "./aws-modules/launch-config"
  lc_name           = "${var.app_name}-lc"
  image_id          = data.aws_ssm_parameter.ecs_ami.value
  ec2_instance_type = var.ec2_instance_type
  ec2_key_name      = var.ec2_key_name
  # iam_instance_profile = module.iam_ecs_role.instance_profile_id
  iam_instance_profile = "${var.app_name}-ecsrole-instance-profile"
  security_groups      = [module.container_instance_security_group.security_group_id]
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
  task_definition_name = "${var.app_name}-taskdefinition"
  container_def_json = var.container_def_file_path
  tags = local.common_tags
}

/*
In spite of explicit dependency specified, for_each still needs values pre populated before apply.
The "for_each" value depends on resource attributes that cannot be determined until apply, so Terraform cannot predict how many instances will be created. To work around this, use
│ the -target argument to first apply only the resources that the for_each depends on.
Thus, creating separte egress rule
resource "aws_security_group_rule" "sg_egress" {
  for_each          = toset([module.alb_security_group.security_group_id, module.container_instance_security_group.security_group_id])
  type              = "egress"
  description       = "allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = each.key

#  depends_on = [module.alb_security_group, module.container_instance_security_group]
}
*/
