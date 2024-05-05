#
# # Only enable this for demonstration purposes.
#
# resource "aws_s3_bucket" "realestate_web_bucket" {
#   bucket = "real-estate-website-bucket"
#   force_destroy = true # I don't care about the data in this bucket. It's just the static website content
#
#   provisioner "local-exec" {
#     environment = { # These need to be set as environment variables for the local-exec provisioner to use them
#       AWS_ACCESS_KEY_ID     = data.vault_generic_secret.aws_creds.data["access_key"]
#       AWS_SECRET_ACCESS_KEY = data.vault_generic_secret.aws_creds.data["secret_key"]
#       AWS_DEFAULT_REGION    = var.region
#     }
#     command = "aws s3 sync ../src/ s3://${self.id}/"
#   }
# }
#
# resource "aws_s3_bucket_public_access_block" "real_estate_web_bucket_block" {
#   bucket = aws_s3_bucket.realestate_web_bucket.id
#
#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }
#
# resource "aws_s3_bucket_website_configuration" "real_estate_static_site_bucket_config" {
#   bucket = aws_s3_bucket.realestate_web_bucket.id
#
#   index_document {
#     suffix = "index.html"
#   }
# }
#
# resource "aws_s3_bucket_policy" "bucket_policy" {
#   depends_on = [aws_route53_record.cdn_record] # IDK why this fails on a first run, but it succeeds on a second run.
#   # So I'm just going to have it run at the end of the apply process.
#   bucket = aws_s3_bucket.realestate_web_bucket.id
#   policy = data.aws_iam_policy_document.s3_policy.json
# }
#
# data "aws_iam_policy_document" "s3_policy" {
#   statement {
#     actions = [
#       "s3:GetObject"
#     ]
#
#     resources = [
#       "${aws_s3_bucket.realestate_web_bucket.arn}/*"
#     ]
#
#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }
#   }
# }
#
# data "vault_generic_secret" "cert" {
#   path = "kv/ssl_certs/nhitruong_com"
# }
#
# resource "aws_acm_certificate" "imported" {
#   provider = aws.useast1
#   certificate_body          = data.vault_generic_secret.cert.data["cert"]
#   private_key               = data.vault_generic_secret.cert.data["privkey"]
#   certificate_chain         = data.vault_generic_secret.cert.data["chain"]
# }
#
# resource "aws_cloudfront_distribution" "s3_distribution" {
#   origin {
#     domain_name = aws_s3_bucket.realestate_web_bucket.bucket_regional_domain_name
#     origin_id   = aws_s3_bucket.realestate_web_bucket.id
#
#     s3_origin_config {
#       origin_access_identity = ""
#     }
#   }
#
#   enabled             = true
#   is_ipv6_enabled     = true
#   comment             = "S3 bucket distribution"
#   default_root_object = "index.html"
#
#   aliases             = ["real-estate-s3-cdn.nhitruong.com"]
#
#   default_cache_behavior {
#     allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = aws_s3_bucket.realestate_web_bucket.id
#
#     forwarded_values {
#       query_string = false
#
#       cookies {
#         forward = "none"
#       }
#     }
#
#     viewer_protocol_policy = "redirect-to-https"
#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#   }
#
#   price_class = "PriceClass_100"
#
#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }
#
#   viewer_certificate {
#     acm_certificate_arn      = aws_acm_certificate.imported.arn
#     ssl_support_method       = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2018"
#   }
# }
#
# locals { # Delegate user cannot get info from the cloudfront distribution.
#   cdn_domain_name = aws_cloudfront_distribution.s3_distribution.domain_name
# }
#
# resource "aws_route53_record" "cdn_record"{
#   provider = aws.delegate
#   zone_id = var.nhitruong_com_hosted_zone_id
#   name    = "real-estate-s3-cdn.nhitruong.com"
#   type    = "CNAME"
#   records = [local.cdn_domain_name]
#   ttl     = "300"
# }