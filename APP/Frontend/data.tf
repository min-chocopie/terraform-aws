data "terraform_remote_state" "eks" {
  backend = "s3"
  config  = {
    bucket  = var.bucket_name
    key     = "terraform/dev/eks.tfstate"
    region  = var.region
    encrypt = true
  }
}
