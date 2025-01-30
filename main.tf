# Provider setup for Google Cloud
provider "google" {
  project     = "kubernetes-447513"
  region      = "us-central1"
  credentials = file("C:\\Users\\it\\Downloads\\kubernetes-447513-2ab3e758c00e.json")
}

# Data source to get the client config
data "google_client_config" "default" {}

# Kubernetes provider
provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

# Helm provider
provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}

# Create GKE cluster with 2 nodes only if it doesn't exist
resource "google_container_cluster" "primary" {
  name                   = "monitoring-cluster"
  location               = "us-central1-c"
  remove_default_node_pool = true
  initial_node_count     = 1

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [initial_node_count] # To avoid recreation due to changes in the node count
  }

  provisioner "local-exec" {
    command = "echo ${google_container_cluster.primary.endpoint}"
  }
}

# Create GKE node pool with 3 nodes
resource "google_container_node_pool" "primary_nodes" {
  name       = "default-pool"
  cluster    = google_container_cluster.primary.id
  location   = "us-central1-c"
  node_count = 3

  node_config {
    machine_type = "g1-small"
    disk_size_gb = 30
    image_type   = "ubuntu_containerd"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  depends_on = [google_container_cluster.primary]
}

# Reference the existing default VPC Network
data "google_compute_network" "default" {
  name = "default"
}

# Create Namespace for monitoring
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }

  depends_on = [
    google_container_cluster.primary,
    google_container_node_pool.primary_nodes
  ]
}

# Prometheus Helm chart
resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "20.0.1"  # Use the latest available version

  depends_on = [kubernetes_namespace.monitoring]
}

# Grafana Helm chart
resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.56.0"  # Use the latest available version

  depends_on = [kubernetes_namespace.monitoring]
}
