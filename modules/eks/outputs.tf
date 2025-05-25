output "eks_cluster_name" {
  description = "The name of the created EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_oidc_url" {
  value = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks_oidc.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.eks_oidc.url
}