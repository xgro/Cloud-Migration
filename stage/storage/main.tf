data "aws_db_snapshot" "database" {
  db_instance_identifier = var.db_instance_identifier
  snapshot_type          = "manual"
  most_recent            = true
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = var.config
}

# Use the last snapshot of the dev database before it was destroyed to create
# a new dev database.
resource "aws_db_instance" "mysql" {
  identifier               = "monolitic-auth-db"
  snapshot_identifier      = data.aws_db_snapshot.database.id
  db_subnet_group_name     = aws_db_subnet_group.this.id
  vpc_security_group_ids   = [data.terraform_remote_state.vpc.outputs.rds-security_group_id]
  instance_class           = "db.t3.micro"
  apply_immediately        = true
  skip_final_snapshot      = true
  delete_automated_backups = false

  lifecycle {
    ignore_changes = [
      snapshot_identifier
    ]
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "main"
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  tags = {
    Name = "My DB subnet group"
  }
}