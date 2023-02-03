terraform {
  backend "s3" {
    bucket  = "minchocopie-eks-tfstate" 
    key     = "terraform/dev/addon/ca.tfstate"
    region  = "ap-northeast-2"
    encrypt = true
  }
}