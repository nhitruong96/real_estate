

resource "aws_route53_record" "configure_bastion_r53_record_nhitruong_com" {
  zone_id = data.aws_route53_zone.local_env_nhitroung_com.zone_id
  name    = "real-estate.${var.environment}.nhitruong.com"
  type    = "A"
  ttl     = 300
  records = [data.aws_instance.bastion_instance.public_ip]
}