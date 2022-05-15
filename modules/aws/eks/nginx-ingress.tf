resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "nginx-ingress" {
  # Cluster must exist before helm release can be deployed.
  depends_on = [
    module.eks,
    aws_iam_policy.worker_policy,
    helm_release.ingress,
  ]

  version = "v4.0.18"

  name       = "nginx-ingress"
  namespace  = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  values = [
    <<VALUES
controller:
  config:
    use-proxy-protocol: 'true'
  nodeSelector:
    kubernetes.io/os: linux
    porter.run/workload-kind: "system"
  tolerations:
  - key: "porter.run/workload-kind"
    operator: "Equal"
    value: "system"
    effect: "NoSchedule"
  admissionWebhooks:
    patch:
      nodeSelector:
        porter.run/workload-kind: "system"
      tolerations:
      - key: "porter.run/workload-kind"
        operator: "Equal"
        value: "system"
        effect: "NoSchedule"
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: '*'
      service.beta.kubernetes.io/aws-load-balancer-type: nlb-ip
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
  metrics:
    annotations:
      prometheus.io/port: '10254'
      prometheus.io/scrape: 'true'
    enabled: true
  podAnnotations:
    prometheus.io/port: '10254'
    prometheus.io/scrape: 'true'
  replicaCount: 2
  resources:
    limits:
      memory: 270Mi
  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app.kubernetes.io/name
              operator: In
              values:
              - ingress-nginx
            - key: app.kubernetes.io/instance
              operator: In
              values:
              - nginx-ingress
            - key: app.kubernetes.io/component
              operator: In
              values:
              - controller
          topologyKey: kubernetes.io/hostname
defaultBackend:
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
