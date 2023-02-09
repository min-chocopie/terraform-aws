# 모니터링용 efs
module "efs_csi_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "efs-csi"
  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = data.terraform_remote_state.eks.outputs.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi"]
    }
  }
}

resource "kubernetes_service_account" "efs_csi" {
  metadata {
    name        = "efs-csi"
    namespace   = "kube-system"
    labels      = {
      "app.kubernetes.io/name"      = "efs-csi"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.efs_csi_role.iam_role_arn
    }
  }
}

resource "helm_release" "efs_csi_driver" {
  name       = "efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  namespace  = "kube-system"

  depends_on = [
    kubernetes_service_account.efs_csi
  ]

  dynamic "set" {
    for_each = {
      "image.repository"      = "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/eks/aws-efs-csi-driver"
      "serviceAccount.create" = "false"
      "serviceAccount.name"   = "efs-csi"
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "aws_security_group" "efs" {
  name   = "efs"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_efs_file_system" "efs" {
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

resource "aws_efs_mount_target" "efs_mount" {
  # private 으로 변경 필요
  count           = "${length(data.terraform_remote_state.vpc.outputs.public_subnets)}"
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = "${data.terraform_remote_state.vpc.outputs.public_subnets[count.index]}"
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_access_point" "efs_ap" {
  file_system_id = aws_efs_file_system.efs.id
}