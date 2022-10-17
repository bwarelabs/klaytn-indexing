output "public_endpoint" {
  value = google_container_cluster.graph-indexer.endpoint
}

output "db_address" {
  value = google_sql_database_instance.graph-indexer.ip_address
}
