resource "aws_security_group" "rds" {
  name   = "eks-db"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block] # 보안 그룹으로 변경 필요
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "rds" {
  identifier = "eks-db"

  db_name                = "eksdb"
  db_subnet_group_name   = data.terraform_remote_state.vpc.outputs.database_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds.id]

  engine         = "mysql"
  engine_version = "8.0.28"
  
  instance_class    = "db.t3.micro"
  allocated_storage = 10
  
  username = var.db_username
  password = var.db_password

  skip_final_snapshot = true
}
