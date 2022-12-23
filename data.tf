data "google_compute_subnetwork" "this" {
  self_link = var.network.subnet_self_link
}

data "google_container_engine_versions" "this" {
  project  = var.project_id
  location = var.location
}

data "google_project" "this" {
  project_id = var.project_id
}
