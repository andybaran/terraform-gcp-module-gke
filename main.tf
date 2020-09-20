terraform {
    required_version = ">= 0.12.0"
    required_providers {
        google = "~> 3.24.0"
    }
}

# Presumably our admins created a project for us using TFE and we're going to get info about that project from the resulting workspace.
data "terraform_remote_state" "project" {
  backend = "remote"
  config = {
    hostname = var.remote-hostname
    organization = var.organization-name
    workspaces = {
      name = var.workspace-name
    }
  }
}

provider "google" {
  credentials = var.creds
  project = var.gcloud_project
  region = var.region
  zone = var.zone
}

# BigQuery for GKE logs? Yes please!  Let's make a dataset
resource "google_bigquery_dataset" "cluster-usage-dataset" {
    dataset_id = var.bq-cluster-usage-dataset
    friendly_name = var.bq-cluster-usage-dataset
    description = "Dataset containing tables related to GKE cluster usage"
    location = "US"
}

# Lets make our lives easy and give the service account from our remote_state GKE cluster admin access
resource "google_project_iam_member" "gke_cluster_admin" {
    project = var.gcloud_project
    role = "roles/container.clusterAdmin"
    member = "serviceAccount:${data.terraform_remote_state.project.outputs.service_account_email}"
}

# Let's get even crazier and give the service account from our remote_state container admin access
resource "google_project_iam_member" "gke_container_admin" {
    project = var.gcloud_project
    role = "roles/container.admin"
    member = "serviceAccount:${data.terraform_remote_state.project.outputs.service_account_email}"
}

# Finally done igonoring all infosec best practices (that's OK this IS NOT in production, right?!)
# ... And now we can create a GKE cluster
resource "google_container_cluster" "primary" {

  depends_on = [google_bigquery_dataset.cluster-usage-dataset,google_project_iam_member.gke_cluster_admin, google_project_iam_member.gke_container_admin]
  name     = var.primary-cluster
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network= data.terraform_remote_state.project.outputs.primary_net

  master_auth {

    # This is going to make deploying workloads to this cluster significantly easier
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