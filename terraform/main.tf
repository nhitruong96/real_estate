terraform {
  backend "s3" {
    bucket       = "prod-levantine-terraform-bucket"
    key          = "real_estate/terraform.tfstate"
    region       = "us-west-2"
    use_lockfile = true
  }
}

variable "region" {}
variable "environment" {}
variable "vault_address" {}
variable "vault_token" {}
variable "levantine_io_hosted_zone_id" {}

# Still needed here: the aws.delegate provider in
# route_53_delegate_records.tf manages this service's live subdomain
# record and genuinely needs Vault for its credentials. Only the
# *default* AWS provider below moves to OIDC.
provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

# Auth for the default (non-delegate) AWS provider is via GitHub Actions
# OIDC role assumption (see iam_oidc_role.tf), not a long-lived
# Vault-stored static key. aws-actions/configure-aws-credentials sets
# AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY/AWS_SESSION_TOKEN as env vars
# before terraform runs, which the AWS provider's default credential
# chain picks up automatically -- nothing to configure here.
provider "aws" {
  region = var.region
}

# NOTE: 2026-08-21 -- the aws.useast1 provider alias (for an ACM cert, per
# the comment that used to be here) was declared but only ever referenced
# by the fully-commented-out CloudFront experiment in s3_hosting.tf.
# Dropped as dead weight; add it back properly (with its own OIDC-based
# auth) if that experiment is ever revived for real.
