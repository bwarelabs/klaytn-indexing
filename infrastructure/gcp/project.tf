resource "google_project_service" "compute-service" {
  project = var.project
  service = "compute.googleapis.com"
}

resource "google_project_service" "gke-service" {
  project = var.project
  service = "container.googleapis.com"
}

resource "google_project_service" "sql-service" {
  project = var.project
  service = "sqladmin.googleapis.com"
}

resource "google_project_service" "networking-service" {
  project = var.project
  service = "servicenetworking.googleapis.com"
}
