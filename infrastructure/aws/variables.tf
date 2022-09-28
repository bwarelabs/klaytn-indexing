variable eks_management_ips  {
  description = "Array of CIDR IP blocks that can access the EKS cluster and the PSQL database"
  default = ["0.0.0.0/0"]
}

variable "vpc_availablitiy_zones" {
  description = "Number of availability zones to use"
  default = 2
}

variable "instance_types" {
  description = "Instance types to be used by the EKS worker group"
  default = ["t3.medium"]
}

variable "aws_region" {
  description = "Region where resources will be provisioned"
  default = "us-west-2"
}

variable "eks_node_group_scaling_desired" {
  description = "Number of worker nodes to be started"
  default = 2
}
variable "eks_node_group_scaling_min" {
  description = "Minimum number of worker nodes"
  default = 1
}
variable "eks_node_group_scaling_max" {
  description = "Maximum number of worker nodes"
  default = 5
}

variable "eks_version" {
  description = "Kubernetes cluster version"
  default = 1.21
}

variable "postgresql_admin_user" {
  description = "Postgresql admin user - will be used by graph-nodes for accessing databases"
  default = "postgres"
}

variable "postgresql_admin_password" {
  description = "Postgresql admin password"
  default = "postgres"
}

variable "postgresql_version" {
  description = "Postgresql version to be used"
  default = "12.7"
}

variable "postgresql_sku_name" {
  description = "Postgresql AWS RDS size"
  default = "db.t3.xlarge"
}

variable "postgresql_alloc_storage" {
  description = "Postgresql allocated storage"
  default = "50"
}

variable "postgresql_max_alloc_storage" {
  description = "Postgresql max allocation storage"
  default = 500
}

variable "postgresql_dbname_indexer" {
  description = "TheGraph Query"
  default = "graph"
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
