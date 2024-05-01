data "aws_instance" "bastion_instance" {
  filter {
    name   = "tag:Name"
    values = ["Bastion"]
  }
}

data "aws_route53_zone" "local_env_nhitroung_com" {
  name = "${var.environment}.nhitruong.com."
}