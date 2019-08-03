provider "aws" {
  profile = "netlight"
  region  = "eu-west-1"
}


provider "kubernetes" {
  config_context = "eks-workshop"
}


locals {
  domain_name = "eks-workshop.edge-labs.com"
  common_tags = {
    Project = "bewh-eks-workshop"
    Creator = "ben-white"
  }
}

data "aws_vpc" "playground" {
  filter {
    name   = "tag:Name"
    values = ["Playground-VPC"]
  }
}

data "aws_subnet_ids" "private_subnets" {
  vpc_id = data.aws_vpc.playground.id
  tags = {
    Name = "*private*"
  }
}

data "aws_subnet_ids" "public_subnets" {
  vpc_id = data.aws_vpc.playground.id
  tags = {
    Name = "*public*"
  }
}

data "aws_route53_zone" "edgelabs" {
  name = "edge-labs.com."
}


resource "aws_route53_zone" "main" {
  name = local.domain_name

  tags = "${merge(
    local.common_tags
  )}"
}

resource "aws_acm_certificate" "cert" {
  domain_name               = local.domain_name
  subject_alternative_names = ["*.${local.domain_name}"]
  validation_method         = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
  zone_id = aws_route53_zone.main.id
  records = [aws_acm_certificate.cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = aws_acm_certificate.cert.arn

  validation_record_fqdns = [
    aws_route53_record.cert_validation.fqdn
  ]
}

resource "aws_route53_record" "ns_record" {
  zone_id = data.aws_route53_zone.edgelabs.zone_id
  name    = local.domain_name
  type    = "NS"
  ttl     = "300"
  records = aws_route53_zone.main.name_servers
}

module "eks" {
  source      = "./eks"
  common_tags = local.common_tags

  vpc_id          = data.aws_vpc.playground.id
  private_subnets = data.aws_subnet_ids.private_subnets.ids
  public_subnets  = data.aws_subnet_ids.public_subnets.ids
}

module "k8s" {
  source = "./k8s"

  zone_id          = aws_route53_zone.main.id
  main_domain      = local.domain_name
  cluster_endpoint = module.eks.cluster_endpoint
  certificate_arn  = aws_acm_certificate.cert.arn
}
