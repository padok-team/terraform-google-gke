output "this" {
  description = "All outputs of the kubernetes cluster."
  value       = google_container_cluster.this
  sensitive   = true
}

output "ip_addresses" {
  value = google_compute_address.this[*]
}

output "global_ip_addresses" {
  value = google_compute_global_address.this[*]
}
