resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds_sng" {
  name = "rds-subnet-group"

  subnet_ids = var.subnet_ids
}


resource "aws_db_instance" "rds_db" {
  allocated_storage    = var.db_allocated_storage
  storage_type         = var.db_storage_type
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.rds_sng.name
  vpc_security_group_ids = [
  aws_security_group.rds_sg.id]
  skip_final_snapshot = var.db_skip_final_snapshot
  tags = merge({
    name = var.db_name
  }, var.tags)
}

