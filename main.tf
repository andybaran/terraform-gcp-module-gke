
provider "google" {
  credentials = base64decode(var.creds)
  project = var.gcloud_project
  region = var.region
  zone = var.zone
}

resource "google_bigquery_dataset" "cluster-usage-dataset" {
    dataset_id = var.bq-cluster-usage-dataset
    friendly_name = var.bq-cluster-usage-dataset
    description = "Dataset containing tables related to GKE cluster usage"
    location = "US"
}

resource "google_container_cluster" "primary" {
  name     = var.primary-cluster
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network= "provisioning-vpc"

  master_auth {

    client_certificate_config {
      issue_client_certificate = true
    }
  }
  resource_usage_export_config {
    enable_network_egress_metering = true
    enable_resource_consumption_metering = true

  bigquery_destination {
    dataset_id = google_bigquery_dataset.cluster-usage-dataset.dataset_id
  }
}
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = var.primary-node-pool
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.primary-node-count

  node_config {
    preemptible  = true
    machine_type = var.primary-node-machine-type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

}