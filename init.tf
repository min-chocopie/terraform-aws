# tfstate를 S3에서 관리하도록 설정
provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "minchocopie-eks-tfstate"
}

# 이전 state로 돌릴 수 있도록 버전 관리 활성화
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}