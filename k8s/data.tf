data "aws_route53_zone" "demo" {
  name         = "demo.aviatrixtest.com"
  private_zone = false
}
