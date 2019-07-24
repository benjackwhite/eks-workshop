provider "aws" {
  profile = "netlight"
  region = "eu-west-1"
}

locals {
  common_tags = {
    Project     = "bewh-eks-workshop"
    Creator     = "ben-white"
  }
}



data "aws_vpc" "playground" {
 filter {
   name = "tag:Name"
   values = ["Playground-VPC"]
 }
}

data "aws_subnet_ids" "private_subnets" {
 vpc_id = "${data.aws_vpc.playground.id}"
 tags = {
   Name = "*private*"
 }
}


data "aws_subnet_ids" "public_subnets" {
 vpc_id = "${data.aws_vpc.playground.id}"
 tags = {
   Name = "*public*"
 }
}


module "eks" {
  source      = "./eks"
  common_tags = "${local.common_tags}"

  vpc_id   = "${data.aws_vpc.playground.id}"
  private_subnets  = ["${data.aws_subnet_ids.private_subnets}"]
  public_subnets  = ["${data.aws_subnet_ids.public_subnets}"]
}
