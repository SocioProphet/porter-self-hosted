resource "helm_release" "metrics-server" {
  # Cluster must exist before helm release can be deployed.
  depends_on = [ 
      module.eks
  ]

  name = "metrics-server"
  namespace = "kube-system"
  repository = "https://charts.bitnami.com/bitnami"
  chart = "metrics-server"
  version = "v5.7.1"

  set {
    name  = "apiService.create"
    value = "true"
  }

  # run metrics-server chart on "system" nodes
  values = [
    <<VALUES
nodeSelector:
  porter.run/system: "true"
VALUES
  ]
}