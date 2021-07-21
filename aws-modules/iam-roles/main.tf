resource "aws_iam_role" "this" {
  name = var.role_name
  tags = var.tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "this" {
    count = (var.create_instance_profile) ? 1 : 0
    name = "${var.role_name}-instance-profile"
    role = aws_iam_role.this.name
}
