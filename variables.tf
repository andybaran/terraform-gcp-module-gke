variable "region" {
  description = "GCP region"
}

variable "zone" {
  description = "GCP zone, needed by dataflow"
}

variable "primary-cluster" {
    description = "Name of primary GKE cluster"
}

variable "primary-node-pool" {
    description = "BigQuery Dataset"
}

variable "primary-node-count" {
  description = "Number of nodes in primary node pool"
}

variable "primary-node-machine-type" {
  description = "Machine type needed for primary node"
}
variable "bq-cluster-usage-dataset" {
  description = "Dataset to store cluster resource usage data"
}

variable "creds" {
  description = "base64decode'd service account token"
}

variable "gcloud_project" {
  description = "google cloud project to create cluster in"
}

variable "organization-name" {
  description = "TFE Organization name"
}

variable "workspace-name" {
  description = "TFE workspace name where project was created"
}