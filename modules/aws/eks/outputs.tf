output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
  sensitive   = true
}

output "cluster_name" {
  description = "EKS cluster ID (name alias)."
  value       = module.eks.cluster_id
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "cluster_ca_data" {
  description = "Cluster CA data"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "kubectl_config" {
  description = "kubectl config as generated by the module."
  value       = module.eks.kubeconfig
  sensitive   = true
}
