resource "google_compute_network" "graph-indexer" {
  name                    = "graph-indexer-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "graph-indexer" {
  name          = "graph-indexer-subnet"
  region        = var.region
  network       = google_compute_network.graph-indexer.name
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_compute_router" "graph-indexer" {
  project = var.project_id
  name    = "graph-indexer-nat-router"
  network = google_compute_network.graph-indexer.name
  region  = var.region
}

resource "google_compute_router_nat" "graph-indexer" {
  name                               = "graph-indexer-router-nat"
  router                             = google_compute_router.graph-indexer.name
  region                             = google_compute_router.graph-indexer.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}