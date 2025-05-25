
variable "cluster_name" {
  description = "The EKS cluster name (used for tagging and ALB Controller Helm values)"
  type        = string
}

variable "oidc_url" {
  description = "OIDC provider URL from EKS"
  type        = string
}
