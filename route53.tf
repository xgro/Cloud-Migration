resource "aws_route53_record" "monolitic" {
  name    = aws_apigatewayv2_domain_name.domain.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.selected.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

data "aws_route53_zone" "selected" {
  name         = "xgro.be"
  # private_zone = true
}

data "aws_acm_certificate" "issued" {
  domain   = "api.xgro.be"
  statuses = ["ISSUED"]
}