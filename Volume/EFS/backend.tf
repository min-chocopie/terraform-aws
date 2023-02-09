terraform {
  backend "s3" {
    bucket  = "minchocopie-eks-tfstate" 
    key     = "terraform/dev/efs.tfstate"
    region  = "ap-northeast-2"
    encrypt = true
  }
}