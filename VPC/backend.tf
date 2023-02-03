terraform {
  backend "s3" {
    bucket  = "minchocopie-eks-tfstate"
    key     = "terraform/dev/vpc.tfstate" # s3 내에서 저장될 경로
    region  = "ap-northeast-2"
    encrypt = true
  }
}