output "cluster_client_cert" {
  value = google_container_cluster.primary.master_auth[0].client_certificate
  description = "Base64 encoded public certificate used by clients to authenticate to the cluster endpoint."
}

output "cluster_client_key" {
  value = google_container_cluster.primary.master_auth[0].client_key
  description = "Base64 encoded private key used by clients to authenticate to the cluster endpoint."
}

output "cluster_ca_certificate" {
  value = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  description = "Base64 encoded public certificate that is the root of trust for the cluster."
}

output "gke_endpoint" {
  value = google_container_cluster.primary.endpoint
  description = "The IP address of this cluster's Kubernetes master."
}

output "cluster_name" {
  value = google_container_cluster.primary.name
  description = "The name of the cluster."
}

output "zone" {
  value = var.zone
  description = "GCP Zone the cluster is in."
}

output "region" {
  value = var.region
  description = "GCP Region the cluster is in."
}

output "gcloud_project" {
  value = var.region
  description = "GCP project the cluser is in.
}