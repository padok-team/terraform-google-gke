output "this" {
  description = "All outputs of the kubernetes cluster."
  value       = google_container_cluster.this
  sensitive   = true
}

output "compute_addresses" {
  value = google_compute_address.this[*]
}

output "compute_global_addresses" {
  value = google_compute_global_address.this[*]
}
