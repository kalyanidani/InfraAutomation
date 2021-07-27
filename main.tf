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

#-------------- data sources ----------------


#-------------- ecs cluster create ----------------

module "ecs_cluster" {
    source = "./aws-modules/ecs-cluster"
    cluster_name = var.cluster_name
}

