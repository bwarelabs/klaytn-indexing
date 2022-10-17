resource "google_service_account" "graph-indexer-gke" {
  account_id   = "graph-indexer-gke"
  display_name = "Graph Indexer GKE"
}