app_name   = "myapp"
deploy_env = "dev"
vpc_id = {
  "dev" = "vpc-ce941db3"
  "qa"  = "xxxxx"
}
aws_profiles = {
  "dev" = "default"
  "qa"  = "qaprofile"
}
ec2_instance_type = "t3.small"
ec2_key_name      = "ec2-key-pair"

availability_zones = {
  "dev" = ["us-east-1a", "us-east-1b"]
}

container_def_file_path = "ecs/app-task-definition.json"
