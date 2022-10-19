# Create CloudSQL Postgres instance
resource "google_sql_database_instance" "graph-indexer-postgres" {
  database_version       = var.postgresql_version
  name                   = "graph-indexer"
  deletion_protection    = false

  settings {
    activation_policy      = "ALWAYS"
    availability_type      = "REGIONAL"
    disk_autoresize        = true
    disk_size              = 256
    disk_type              = "PD_SSD"
    tier                   = var.postgresql_database_tier
    backup_configuration {
      binary_log_enabled = false
      enabled            = true
      start_time         = "02:00"
    }
    database_flags {
      name  = "log_temp_files"
      value = "-1"
    }
    database_flags {
      name  = "log_lock_waits"
      value = "on"
    }
    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.graph-indexer.id
      authorized_networks {
        name  = "CIDR IP Blocks which will have access to the database"
        value = var.gke_management_ips
      }
    }
  }

  depends_on = [ 
    google_project_service.sql-service,
    google_service_networking_connection.graph-indexer-cloudsql-private-vpc-connection
  ]
}

resource "google_sql_database" "graph-indexer-postgres-database" {
  name     = var.postgresql_dbname_indexer
  instance = google_sql_database_instance.graph-indexer-postgres.name
  depends_on = [ google_sql_database_instance.graph-indexer-postgres ]
}

resource "google_sql_user" "graph-indexer-postgres-user" {
  name     = var.postgresql_admin_user
  password = var.postgresql_admin_password
  instance = google_sql_database_instance.graph-indexer-postgres.name
  depends_on = [ google_sql_database_instance.graph-indexer-postgres ]
}