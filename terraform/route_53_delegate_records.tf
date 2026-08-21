data "vault_generic_secret" "aws_delegation_creds" {
  path = "kv/aws/iam_access_keys/subdomain_delegation"
}

provider "aws" {
  # NOTE: The delegation account is used for DNS subdomain delegation between the root account and the subdomain account
  alias = "delegate"
  region = var.region
  access_key = try(data.vault_generic_secret.aws_delegation_creds.data["access_key"], null)
  secret_key = try(data.vault_generic_secret.aws_delegation_creds.data["secret_key"], null)
}

# 2026-08-21: moved onto the levantine.io umbrella -- nhitruong.com is no
# longer owned/renewed (confirmed: no such zone exists in this AWS
# account). This now matches what's actually live (VIRTUAL_HOST in the
# ansible repo's group_vars/VMWareDockerHosts, "real-estate.levantine.io"
# -- note the hyphenated service name, distinct from this repo's own
# "real_estate" GitHub slug) and the pattern already used by
# thisper/processMining.
resource "aws_route53_record" "configure_delegate_record" {
  provider = aws.delegate
  zone_id = var.levantine_io_hosted_zone_id
  name    = "real-estate.levantine.io"
  type    = "A"
  ttl     = 300
  records = [data.aws_instance.bastion_instance.public_ip]
}
