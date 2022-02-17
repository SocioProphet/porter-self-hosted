resource "helm_release" "cluster-autoscaler" {
  # Cluster must exist before helm release can be deployed.
  depends_on = [ 
      module.eks, 
      aws_iam_policy.worker_policy
  ]

  version = "9.4.0"

  name = "cluster-autoscaler-chart"
  namespace = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart = "cluster-autoscaler"

  set {
      name  = "awsRegion"
      value = var.aws_region
  }

  set {
      name = "rbac.create"
      value = "true"
  }

  set {
      name = "rbac.serviceAccount.name"
      value = "cluster-autoscaler-aws-cluster-autoscaler-chart"
  }

  set {
      name = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.iam_assumable_role_admin.this_iam_role_arn
  }

  set {
      name = "autoDiscovery.clusterName"
      value = var.env_name
  }

  # run cluster-autoscaler chart on "system" nodes
  values = [
    <<VALUES
nodeSelector:
  porter.run/system: "true"
VALUES
  ]
}