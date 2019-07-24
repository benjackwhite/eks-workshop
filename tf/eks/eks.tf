locals {
  map_roles = [
    {
      role_arn = "${data.aws_iam_role.aws-developers.arn}"
      username = "aws-developer"
      group    = "system:masters"
    }
  ]
}

data "aws_iam_role" "aws-developers" {
  name = "AD-Developer"
}

module "abakus-eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = "${var.cluster_name}"
  cluster_version = "${var.cluster_version}"
  subnets      = ["${sort(concat(var.private_subnets, var.public_subnets))}"]
  vpc_id       = "${var.vpc_id}"
  map_roles    = "${local.map_roles}"
  write_aws_auth_config = "${var.write_aws_auth_config}"
  write_kubeconfig = "${var.write_kubeconfig}"

  worker_groups = [
    {
      instance_type = "${var.worker_instance_type}"
      asg_min_size  = "${var.worker_asg_min_size}"
      asg_max_size  = "${var.worker_asg_max_size}"
      asg_desired_capacity = "${var.worker_asg_desired_capacity}"
      subnets      = "${join(",", sort(var.private_subnets))}"
      pre_userdata = <<EOF
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
sed -i -e 's/2048/65536/g' /etc/docker/daemon.json
sed -i -e 's/8192/65536/g' /etc/docker/daemon.json
systemctl restart docker.service
EOF
    }
  ]
}

resource "aws_iam_role_policy" "additional-worker-policy" {
  name   = "eks-worker-additional"
  role   = "${module.abakus-eks.worker_iam_role_name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

# NOTE: This policy allows use of SSM to connect to the nodes. Uncomment if needed
resource "aws_iam_role_policy_attachment" "workers_AmazonEC2RoleforSSM" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = "${module.abakus-eks.worker_iam_role_name}"
}