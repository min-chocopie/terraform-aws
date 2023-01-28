module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = local.cluster_name
  cluster_version = "1.23"

  vpc_id     = module.vpc.vpc_id
  # subnet_ids = module.vpc.public_subnets
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  eks_managed_node_groups = {
    node_group = {
      name = "node-group"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 5
      desired_size = 2

      tags = {
        "k8s.io/cluster-autoscaler/enabled" : "true"
        "k8s.io/cluster-autoscaler/${local.cluster_name}" : "owned"
      }
    }
    
    # frontend_ng = {
    #   name = "frontend-ng"

    #   instance_types = ["t3.small"]

    #   min_size     = 1
    #   max_size     = 2
    #   desired_size = 1

    #   labels = {
    #     tier = "frontend"
    #   }

    #   tags = {
    #     "k8s.io/cluster-autoscaler/enabled" : "true"
    #     "k8s.io/cluster-autoscaler/${local.cluster_name}" : "owned"
    #     "k8s.io/cluster-autoscaler/node-template/label/tier" : "frontend"
    #     "tier" : "frontend"
    #   }
    # }

    # backend_ng = {
    #   name = "backend-ng"

    #   instance_types = ["t3.small"]

    #   min_size     = 1
    #   max_size     = 2
    #   desired_size = 1

    #   labels = {
    #     tier = "backend"
    #   }

    #   tags = {
    #     "k8s.io/cluster-autoscaler/enabled" : "true"
    #     "k8s.io/cluster-autoscaler/${local.cluster_name}" : "owned"
    #     "tier" : "backend"
    #     # "k8s.io/cluster-autoscaler/node-template/label/tier" : "backend"
    #   }
    # }
  } 
}