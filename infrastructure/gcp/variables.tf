variable "project" {
  description = "Google Cloud Platform project ID"
}

variable "region" {
  description = "GCP Region to use"
  default = "us-central1"
}

variable "gke_management_ips" {
  description = "Array of CIDR IP blocks that can access the GKE cluster"
  default = "0.0.0.0/0"
}

variable "gke_node_locations" {
  description = "List of region zones to be used for deploying GKE Cluster worker nodes"
  default = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

variable "nginx_ingress_helm_chart_name" {
  type        = string
  default     = "ingress-nginx"
  description = "Helm chart name to be installed"
}

variable "nginx_ingress_helm_chart_version" {
  type        = string
  description = "Version of the Helm chart"
  default     = "3.35.0"
}

variable "nginx_ingress_helm_release_name" {
  type        = string
  default     = "ingress-nginx"
  description = "Helm release name"
}

variable "nginx_ingress_helm_repo_url" {
  type        = string
  default     = "https://kubernetes.github.io/ingress-nginx"
  description = "Helm repository"
}

variable "k8s_create_namespace" {
  type        = bool
  default     = true
  description = "Whether to create k8s namespace with name defined by `k8s_namespace`"
}

variable "k8s_namespace" {
  type        = string
  default     = "ingress-controller"
  description = "The K8s namespace in which the ingress-nginx has been created"
}

variable "postgresql_version" {
  default     = "POSTGRES_12"
  description = "Postgresql version"  
}

variable "postgresql_database_tier" {
  type        = string
  default     = "db-custom-8-30720"
  description = "The type of machine to use for the database"
}

variable "postgresql_admin_user" {
  description = "Postgresql admin user"
  default     = "postgres"
}
variable "postgresql_admin_password" {
  description = "Postgresql admin user password"
  default     = "postgres"
}
