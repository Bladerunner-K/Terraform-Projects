resource "aws_route53_zone" "primary" {
  name = var.domain
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.primary.zone_id
  name = var.domain
  type = "A"

  alias {
    name = aws_lb.loadb.dns_name
    zone_id = aws_lb.loadb.zone_id
    evaluate_target_health = true
  }
}