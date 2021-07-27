output "role_arn" {
    description = "Role arn"
    value = aws_iam_role.this.arn
}

output "role_id" {
    description = "Role id"
    value = aws_iam_role.this.id
}

output "instance_profile_arn" {
    description = "Instance profile arn"
    value = aws_iam_instance_profile.this.*.arn
}

output "instance_profile_id" {
    description = "Instance profile id"
    value = aws_iam_instance_profile.this.*.id
}
