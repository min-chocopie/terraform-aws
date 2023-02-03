variable "bucket_name" {
  type    = string
  default = "minchocopie-eks-tfstate" 
}

variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "server_name" {
  type    = string
  default = "simple-server"
}

variable "server_port" {
  type    = number
  default = 8080
}

variable "server_registry" {
  type = string
}

variable "db_username" {
  type    = string
}

variable "db_password" {
  type    = string
}
