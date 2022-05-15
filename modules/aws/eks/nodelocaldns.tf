resource "helm_release" "node-local-dns" {
  # Cluster must exist before helm release can be deployed.
  depends_on = [
    module.eks,
    aws_iam_policy.worker_policy,
  ]

  version = "0.13.0"

  name       = "node-local-dns"
  namespace  = "kube-system"
  repository = "https://chart-addons.getporter.dev"
  chart      = "node-local"
}
