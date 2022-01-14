output "this" {
  description = "All outputs of the kubernetes cluster."
  value       = google_container_cluster.this
  sensitive   = true
}
