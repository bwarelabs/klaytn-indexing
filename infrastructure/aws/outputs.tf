output "public_ips" {
  value = aws_nat_gateway.graph-indexer-eks-nat-gateway.*.public_ip
}

output "db_address" {
  value = aws_db_instance.graph-indexer-postgres.address
}