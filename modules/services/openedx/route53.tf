data aws_route53_zone "route53_zone" {
  name = "${var.customer_domain}."
  private_zone = false
  
  count = "${var.enable_route53 ? 1 : 0}"
}

resource aws_route53_record "subdomain_lb_record" {
  count = "${var.enable_route53 ? length(var.route53_subdomains) : 0}"
  zone_id = data.aws_route53_zone.route53_zone[0].zone_id
  name = "${var.route53_subdomains[count.index]}.${data.aws_route53_zone.route53_zone[0].name}"
  type = "A"

  alias {
    evaluate_target_health = false
    name = aws_lb.edxapp.dns_name
    zone_id = aws_lb.edxapp.zone_id
  }
  
}

resource aws_route53_record "main_domain_lb_record" {
  allow_overwrite = true
  zone_id = data.aws_route53_zone.route53_zone[0].zone_id
  name = data.aws_route53_zone.route53_zone[0].name
  type = "A"

  alias {
    evaluate_target_health = false
    name = aws_lb.edxapp.dns_name
    zone_id = aws_lb.edxapp.zone_id
  }
  
  count = "${var.enable_route53 ? 1 : 0}"
}
