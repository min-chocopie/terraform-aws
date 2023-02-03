module "lb_controller_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "load-balancer-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = data.terraform_remote_state.eks.outputs.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "kubernetes_service_account" "alb_service_account" {
  metadata {
    name        = "aws-load-balancer-controller"
    namespace   = "kube-system"
    labels      = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.lb_controller_role.iam_role_arn
    }
  }
}

resource "helm_release" "lb_controller" {
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  namespace  = "kube-system"

  depends_on = [
    kubernetes_service_account.alb_service_account
  ]

  dynamic "set" {
    for_each = {
      "image.repository"      = "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon/aws-load-balancer-controller"
      "region"                = var.region
      "vpcId"                 = data.terraform_remote_state.vpc.outputs.vpc_id
      "clusterName"           = data.terraform_remote_state.eks.outputs.cluster_name
      "serviceAccount.create" = "false"
      "serviceAccount.name"   = "aws-load-balancer-controller"
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}
