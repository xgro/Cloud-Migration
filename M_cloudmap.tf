resource "aws_service_discovery_private_dns_namespace" "private" {
  name = "private"
  vpc  = module.vpc_mono.vpc_id
}

resource "aws_service_discovery_service" "shared" {
  name = "shared"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private.id

    dns_records {
      ttl  = 300
      type = "A"
    }

    routing_policy = "WEIGHTED"
  }
}

resource "aws_service_discovery_instance" "ec2" {
  instance_id = "monolithic-instance"
  service_id  = aws_service_discovery_service.shared.id

  attributes = {
    AWS_INSTANCE_IPV4 = module.ec2_instance.private_ip
    AWS_INSTANCE_PORT = 80
    custom_attribute  = "custom"
  }
}
