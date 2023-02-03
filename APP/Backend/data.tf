data "terraform_remote_state" "eks" {
  backend = "s3"
  config  = {
    bucket  = var.bucket_name
    key     = "terraform/dev/eks.tfstate"
    region  = var.region
    encrypt = true
  }
}

data "terraform_remote_state" "rds" {
  backend = "s3"
  config  = {
    bucket  = var.bucket_name
    key     = "terraform/dev/rds.tfstate"
    region  = var.region
    encrypt = true
  }
}
