resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

module "eks" {
  depends_on = [
    aws_security_group.worker_group_mgmt_one,
    aws_security_group.worker_group_mgmt_two,
  ]

  source          = "terraform-aws-modules/eks/aws"
  version         = "17.22.0"
  cluster_name    = var.env_name
  cluster_version = "1.20"
  subnets         = var.private_subnets
  enable_irsa     = true

  vpc_id = var.vpc_id

  worker_groups_launch_template = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.medium"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]

      kubelet_extra_args = join(" ", [
        "--node-labels porter.run/system=true",
        "--cluster-dns 172.20.0.10",
        "--cluster-dns 169.254.20.10"
      ])
    },
    {
      name                          = "worker-group-2"
      instance_type                 = var.machine_type
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
      asg_max_size                  = var.max_instances

      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.env_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]

      kubelet_extra_args = join(" ", [
        "--node-labels porter.run/autoscaling=enabled",
        "--cluster-dns 172.20.0.10",
        "--cluster-dns 169.254.20.10"
      ])
    },
  ]

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  workers_additional_policies = [
    aws_iam_policy.worker_policy.arn,
    aws_iam_policy.worker_autoscaling.arn
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

resource "aws_iam_policy" "worker_policy" {
  name        = "${var.env_name}-${random_string.suffix.result}"
  description = "Worker policy for the ALB Ingress"

  policy = file("${path.module}/iam-policy.json")
}

resource "aws_iam_policy" "worker_autoscaling" {
  name_prefix = "eks-worker-autoscaling-${module.eks.cluster_id}"
  description = "EKS worker node autoscaling policy for cluster ${module.eks.cluster_id}"

  policy = data.aws_iam_policy_document.worker_autoscaling.json
}

data "aws_iam_policy_document" "worker_autoscaling" {
  statement {
    sid    = "eksWorkerAutoscalingAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "eksWorkerAutoscalingOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${module.eks.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

resource "helm_release" "ingress" {
  # EKS and IAM policy are pre-requisites
  depends_on = [module.eks, aws_iam_policy.worker_policy]
  name       = "ingress-controller"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  version    = "v1.1.5"

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "clusterName"
    value = var.env_name
  }

  values = [
    <<VALUES
nodeSelector:
  porter.run/system: "true"
VALUES
  ]
}
