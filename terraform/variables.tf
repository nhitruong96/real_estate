data "aws_instance" "bastion_instance" {
  filter {
    name   = "tag:Name"
    values = ["Bastion"]
  }
}
