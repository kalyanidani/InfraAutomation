aws_profiles = {
  "dev" = "default"
  "qa"  = "qaprofile"
}
deploy_env = "dev"
app_name   = "mypoetryapp"
/*
ec2_ami_id = {
  "dev" = "ami-0747bdcabd34c712a"
}
*/

ec2_instance_type = "t2.micro"
ec2_key_name      = "ec2-key-pair"
security_groups = {
  "dev" = ["sg-5d735258"]
}

availability_zones = {
  "dev" = ["us-east-1a", "us-east-1b"]
}