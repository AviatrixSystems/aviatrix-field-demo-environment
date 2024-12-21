resource "aws_iam_user" "avx_demo" {
  name          = "avx-demo"
  force_destroy = true
}

resource "aws_iam_policy_attachment" "avx_demo" {
  name       = "AdministratorAccess"
  users      = [aws_iam_user.avx_demo.name]
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  lifecycle {
    ignore_changes = [roles]
  }
}

resource "null_resource" "avx_demo" {
  provisioner "local-exec" {
    command     = <<-EOT
      aws iam create-login-profile --user-name=${aws_iam_user.avx_demo.name} --password=${local.tfvars.workload_instance_password} --no-password-reset-required --profile "demo_operations"
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}


data "aws_iam_policy_document" "k8s" {
  statement {
    effect = "Allow"

    actions = [
      "eks:ListClusters",
      "eks:DescribeCluster",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTags"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "k8s" {
  name   = "aviatrix-k8s"
  path   = "/"
  policy = data.aws_iam_policy_document.k8s.json
}

data "aws_iam_role" "avx" {
  name = "aviatrix-role-app"
}

resource "aws_iam_policy_attachment" "k8s" {
  name       = "aviatrix-k8s"
  roles      = [data.aws_iam_role.avx.name]
  policy_arn = aws_iam_policy.k8s.arn
}
