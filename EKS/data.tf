data "terraform_remote_state" "vpc" {
  backend = "s3"
  config  = {
    bucket  = var.bucket_name
    key     = "terraform/dev/vpc.tfstate"
    region  = var.region
    encrypt = true
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}