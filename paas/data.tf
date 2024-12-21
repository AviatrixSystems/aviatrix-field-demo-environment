data "aws_caller_identity" "current" {
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}
