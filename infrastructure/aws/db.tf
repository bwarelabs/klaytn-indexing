# Create RDS Postgres instance
resource "aws_db_instance" "graph-indexer-postgres" {
  engine                 = "postgres"
  engine_version         = var.postgresql_version
  instance_class         = var.postgresql_sku_name
  identifier             = var.postgresql_dbname_indexer
  db_name                = var.postgresql_dbname_indexer
  username               = var.postgresql_admin_user
  password               = var.postgresql_admin_password
  skip_final_snapshot    = true
  max_allocated_storage  = var.postgresql_max_alloc_storage
  allocated_storage      = var.postgresql_alloc_storage
  vpc_security_group_ids = [aws_security_group.graph-indexer.id]
  db_subnet_group_name   = aws_db_subnet_group.graph-indexer-rds-subnet-group.name
  publicly_accessible    = true

  tags = {
    Name = "graph-indexer-cluster-worker-group"
  }

  depends_on = [
    aws_subnet.graph-indexer-rds-subnets,
    aws_route_table_association.graph-indexer-rds-routing-table-association
  ]  
}
