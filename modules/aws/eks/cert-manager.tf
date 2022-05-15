resource "kubernetes_namespace" "cert_manager" {

  depends_on = [
    module.eks,
    aws_iam_policy.worker_policy
  ]

  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert-manager" {
  # Cluster must exist before helm release can be deployed.
  depends_on = [
    module.eks,
    aws_iam_policy.worker_policy
  ]

  name       = "cert-manager"
  namespace  = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.5.5"

  set {
    name  = "installCRDs"
    value = "true"
  }

  # run cert-manager chart on "system" nodes
  values = [
    <<VALUES
nodeSelector:
  porter.run/workload-kind: "system"
tolerations:
- key: "porter.run/workload-kind"
  operator: "Equal"
  value: "system"
  effect: "NoSchedule"
webhook:
  nodeSelector:
    porter.run/workload-kind: "system"
  tolerations:
  - key: "porter.run/workload-kind"
    operator: "Equal"
    value: "system"
    effect: "NoSchedule"
cainjector:
  nodeSelector:
    porter.run/workload-kind: "system"
  tolerations:
  - key: "porter.run/workload-kind"
    operator: "Equal"
    value: "system"
    effect: "NoSchedule"
VALUES
  ]
}

resource "helm_release" "clusterissuer" {
  # Cluster must exist before helm release can be deployed.
  depends_on = [
    module.eks,
    aws_iam_policy.worker_policy,
    helm_release.cert-manager,
  ]

  name       = "https-issuer"
  namespace  = "cert-manager"
  repository = "https://chart-addons.getporter.dev"
  chart      = "https-issuer"

  set {
    name  = "email"
    value = var.issuer_email
  }
}
