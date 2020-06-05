data "terraform_remote_state" "project" {
  backend = "remote"

  config = {
    hostname = "app.terraform.io"
    organization = "akb-test"
    workspaces = {
      name = "GCP-IOT"  #TODO: This shouldn't be hardcoded...let it come in as a var
    }
  }
}


provider "google" {
  credentials = base64decode(data.terraform_remote_state.project.outputs.service_account_token)
  project     = data.terraform_remote_state.project.outputs.short_project_id
  region = var.region
  zone = var.zone
}

resource "google_bigquery_dataset" "cluster-usage-dataset" {

    dataset_id = var.bq-cluster-usage-dataset
    friendly_name = var.bq-cluster-usage-dataset
    description = "Dataset containing tables related GKE cluster usage"
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

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
  resource_usage_export_config {
    enable_network_egress_metering = true
    enable_resource_consumption_metering = true

  bigquery_destination {
    dataset_id = var.bq-cluster-usage-dataset
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