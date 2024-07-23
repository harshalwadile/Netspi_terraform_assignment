resource "aws_iam_role" "s3_access_role" {
  name               = "s3-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name   = "s3-access-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "s3:*",
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access_role_attachment" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_instance_profile" "net_instance_profile" {
  name = "s3accessrole"
  role = aws_iam_role.s3_access_role.name
}

output "net_inst_profile" {
  value = aws_iam_instance_profile.net_instance_profile.name
}
