resource "aws_iam_role_policy_attachment" "this" {
  role       = var.role_id
  policy_arn = var.policy_arn
}

/*
resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = aws_iam_role.this.id
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_instance_core" {
  count = var.include_ssm ? 1 : 0

  role       = aws_iam_role.this.id
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = aws_iam_role.this.id
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/CloudWatchLogsFullAccess"
}
*/
