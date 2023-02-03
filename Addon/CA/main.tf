data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    effect  = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${module.eks.cluster_id}"
      values   = ["owned"]
    }
  }
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name_prefix = "cluster-autoscaler"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

module "cluster_autoscaler_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  create_role                   = true
  role_name                     = "cluster-autoscaler"
  provider_url                  = replace(data.terraform_remote_state.eks.outputs.oidc_provider_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:cluster-autoscaler"]
}

resource "helm_release" "cluster_autoscaler" {
  name             = "cluster-autoscaler"
  namespace        = "kube-system"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"

  dynamic "set" {
    for_each = {
      "awsRegion"                                                      = var.region
      "autoDiscovery.clusterName"                                      = data.terraform_remote_state.eks.outputs.cluster_name
      "autoDiscovery.enabled"                                          = true
      "rbac.create"                                                    = true
      "rbac.serviceAccount.name"                                       = "cluster-autoscaler"
      "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.cluster_autoscaler_role.iam_role_arn
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}