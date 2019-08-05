variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "cluster_name" {
  default = "benwhite-eks-workshop"
}

variable "cluster_version" {
  default = "1.13"
}

variable "vpc_id" {
  description = "(required) ID of the VPC that your ECS cluster will be deployed to"
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

# Number of pods is limited by instance type: https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt
variable "worker_instance_type" {
  default = "t3.medium"
}

variable "worker_asg_min_size" {
  default = 1
}

variable "worker_asg_max_size" {
  default = 6
}

variable "worker_asg_desired_capacity" {
  default = 3
}

variable "write_aws_auth_config" {
  default = false
}

variable "write_kubeconfig" {
  default = false
}

