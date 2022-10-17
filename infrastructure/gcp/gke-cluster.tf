resource "google_container_cluster" "graph-indexer" {
  name                     = "graph-indexer"
  location                 = var.region
  node_locations           = var.gke_node_locations
  initial_node_count       = 1

  network    = google_compute_network.graph-indexer.name
  subnetwork = google_compute_subnetwork.graph-indexer.name

  node_config {
    service_account = google_service_account.graph-indexer-gke.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      name = "graph-indexer"
    }
    tags = ["graph-indexer"]
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
  }

  master_authorized_networks_config {
    cidr_blocks {
        cidr_block = var.gke_management_ips
        display_name = "CIDR IP Blocks which will have access to the cluster"
    }
  }

  timeouts {
    create = "30m"
    update = "40m"
  }

  depends_on = [ 
    google_compute_network.vpc,
    google_service_account.graph-indexer-gke
  ]
}

resource "helm_release" "nginx-ingress" {

  repository = var.nginx_ingress_helm_repo_url
  chart      = var.nginx_ingress_helm_chart_name
  version    = var.nginx_ingress_helm_chart_version

  create_namespace = var.k8s_create_namespace
  namespace        = var.k8s_namespace
  name             = var.nginx_ingress_helm_release_name


  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  depends_on = [
    google_container_cluster.graph-indexer,
  ]
} 
