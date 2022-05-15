resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus" {
  # Cluster must exist before helm release can be deployed.
  depends_on = [
    module.eks,
    aws_iam_policy.worker_policy,
  ]

  version = "v15.5.3"

  name       = "prometheus"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"

  # node selectors are set for everything except "node-exporter", which is a daemonset
  # and should run on every node
  values = [
    <<VALUES
alertmanager:
  nodeSelector:
    porter.run/workload-kind: "system"
  tolerations:
  - key: "porter.run/workload-kind"
    operator: "Equal"
    value: "system"
    effect: "NoSchedule"
  resources:
    limits:
      cpu: 200m
      memory: 256Mi
    requests:
      cpu: 10m
      memory: 64Mi
server:
  nodeSelector:
    porter.run/workload-kind: "system"
  tolerations:
  - key: "porter.run/workload-kind"
    operator: "Equal"
    value: "system"
    effect: "NoSchedule"
  resources:
    limits:
      cpu: 500m
      memory: 2048Mi
    requests:
      cpu: 100m
      memory: 128Mi
pushgateway:
  nodeSelector:
    porter.run/workload-kind: "system"
  tolerations:
  - key: "porter.run/workload-kind"
    operator: "Equal"
    value: "system"
    effect: "NoSchedule"
  resources:
    requests:
      memory: 30Mi
      cpu: 100m
    limits:
      memory: 50Mi
      cpu: 200m
nodeExporter:
  tolerations:
  - key: "porter.run/workload-kind"
    operator: "Equal"
    value: "system"
    effect: "NoSchedule"
  resources:
    requests:
      memory: 30Mi
      cpu: 100m
    limits:
      memory: 50Mi
      cpu: 200m
kube-state-metrics:
  nodeSelector:
    porter.run/workload-kind: "system"
  tolerations:
  - key: "porter.run/workload-kind"
    operator: "Equal"
    value: "system"
    effect: "NoSchedule"
  resources:
    requests:
      memory: 250Mi
      cpu: 100m
    limits:
      memory: 400Mi
      cpu: 200m
VALUES
  ]
}
