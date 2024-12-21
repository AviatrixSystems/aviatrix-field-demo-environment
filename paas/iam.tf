data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm" {
  name               = "aviatrix-role-ssm"
  description        = "EC2 IAM Role for SSM"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy_attachment" "ssm" {
  name       = "AmazonSSMManagedInstanceCore"
  roles      = [aws_iam_role.ssm.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "aviatrix-role-ssm"
  role = aws_iam_role.ssm.name
}
