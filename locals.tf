locals {
  region = "ap-northeast-2"

  vpc_name     = "eks-vpc"
  cluster_name = "eks-cluster"

  server_name = "simple-server"
  client_name = "simple-client"
  
  server_port = 8080
  client_port = 80
}