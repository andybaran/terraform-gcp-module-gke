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

variable "organization-name" {
  description = "TF Organization name"
}

variable "workspace-name" {
  description = "workspace to source project from"
}

variable "creds" {
  description = "service account to that owns project"
}

variable "gcloud_project" {
  description = "google cloud project to create cluster in"
}