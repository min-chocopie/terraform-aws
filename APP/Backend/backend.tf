terraform {
  backend "s3" {
    bucket  = "minchocopie-eks-tfstate" 
    key     = "terraform/dev/backend.tfstate"
    region  = "ap-northeast-2"
    encrypt = true
  }
}