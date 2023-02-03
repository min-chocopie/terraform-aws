# module "cluster_autoscaler_role" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  
#   role_name                        = "cluster-autoscaler"
#   attach_cluster_autoscaler_policy = true

#   oidc_providers = {
#     main = {
#       provider_arn               = data.terraform_remote_state.eks.outputs.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:cluster-autoscaler"]
#     }
#   }
# }

# resource "helm_release" "cluster_autoscaler-back" {
#   name             = "cluster-autoscaler"
#   namespace        = "kube-system"
#   repository       = "https://kubernetes.github.io/autoscaler"
#   chart            = "cluster-autoscaler"

#   dynamic "set" {
#     for_each = {
#       "awsRegion"                                                      = var.region
#       "autoDiscovery.clusterName"                                      = data.terraform_remote_state.eks.outputs.cluster_name
#       "autoDiscovery.enabled"                                          = true
#       "rbac.create"                                                    = true
#       "rbac.serviceAccount.name"                                       = "cluster-autoscaler"
#       "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.cluster_autoscaler_role.iam_role_arn
#     }
#     content {
#       name  = set.key
#       value = set.value
#     }
#   }
# }