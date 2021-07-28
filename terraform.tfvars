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

ec2_user_data_file_path = "ecs/ec2_instantiation.sh"

alb_subnet_ids = ["subnet-020d014f", "subnet-ebdea0b4"]

alb_listener_port = 80

alb_listener_protocol = "HTTP"

alb_listener_default_response = "Reply from server: Welcome to default listener hit"