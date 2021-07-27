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


#-------------- ecs cluster create ----------------

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
