resource "google_project_service" "compute-service" {
  project = var.project
  service = "compute.googleapis.com"
  disable_dependent_services = true
  # Can't disable it once it's enabled
  disable_on_destroy = false
}

resource "google_project_service" "gke-service" {
  project = var.project
  service = "container.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "sql-service" {
  project = var.project
  service = "sqladmin.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "networking-service" {
  project = var.project
  service = "servicenetworking.googleapis.com"
  disable_dependent_services = true
}
