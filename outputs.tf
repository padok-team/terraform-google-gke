output "kubernetes_cluster" {
  value       = google_container_cluster.this
  sensitive   = true
  description = "All outputs of the kubernetes cluster"
}
