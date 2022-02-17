resource "kubernetes_namespace" "monitoring" {
  metadata {
    name      = "monitoring"
  }
}

resource "helm_release" "prometheus" {
  # Cluster must exist before helm release can be deployed.
  depends_on = [ 
      module.eks, 
      aws_iam_policy.worker_policy,
  ]

  version = "v14.4.1"

  name = "prometheus"
  namespace = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "prometheus"

  # node selectors are set for everything except "node-exporter", which is a daemonset
  # and should run on every node
  values = [
    <<VALUES
alertmanager:
  nodeSelector:
    porter.run/system: "true"
server:
  nodeSelector:
    porter.run/system: "true"
pushgateway:
  nodeSelector:
    porter.run/system: "true"
kube-state-metrics:
  nodeSelector:
    porter.run/system: "true"
VALUES
  ]
}