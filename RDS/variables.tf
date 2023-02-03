variable "bucket_name" {
  type    = string
  default = "minchocopie-eks-tfstate" 
}

variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "db_username" {
  type    = string
}

variable "db_password" {
  type    = string
}
