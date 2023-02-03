module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = var.cluster_name
  cluster_version = 1.23

  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  # subnet_ids      = data.terraform_remote_state.vpc.outputs.public_subnets
  subnet_ids      = data.terraform_remote_state.vpc.outputs.private_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  eks_managed_node_groups = {
    node_group = {
      name = "node-group"

      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 3
      desired_size = 1

      tags = {
        "k8s.io/cluster-autoscaler/enabled" : "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" : "owned"
      }
    }
  }
}
