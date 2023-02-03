variable "bucket_name" {
  type    = string
  default = "minchocopie-eks-tfstate" 
}

variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "client_name" {
  type    = string
  default = "simple-client"
}

variable "client_port" {
  type    = number
  default = 80
}

variable "client_registry" {
  type = string
}
