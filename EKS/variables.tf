variable "bucket_name" {
  type    = string
  default = "minchocopie-eks-tfstate" 
}

variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "cluster_name" {
  type    = string
  default = "eks-cluster"
}