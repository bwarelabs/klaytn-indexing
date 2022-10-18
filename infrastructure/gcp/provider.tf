terraform {
  required_version = ">= 0.13"
}

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
  required_version = ">= 0.13"
}

provider "google" {
  project = var.project
  region  = var.region
}

data "google_client_config" "gcloud" {}

provider "helm" {
  kubernetes {
    host                   = google_container_cluster.graph-indexer.endpoint
    token                  = data.google_client_config.gcloud.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.graph-indexer.master_auth.0.cluster_ca_certificate)
  }
}