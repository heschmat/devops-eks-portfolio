resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.3.4" # pick a stable version

  create_namespace = true

  values = [
    <<-EOT
    server:
      service:
        #type: LoadBalancer   # exposes ArgoCD via AWS ELB
        type: ClusterIP   # internal only, exposed via Ingress + ALB
    EOT
  ]
}

# # 🔐 Be mindful: sensitive outputs are hidden but still stored in state — protect your state.
# # Fetch the initial admin secret
# data "kubernetes_secret" "argocd_admin" {
#   metadata {
#     name      = "argocd-initial-admin-secret"
#     namespace = "argocd"
#   }
# }

# # Decode the password and output it
# output "argocd_initial_admin_password" {
#   value     = data.kubernetes_secret.argocd_admin.data["password"]
#   sensitive = true
# }
