resource "google_service_account" "node_pool_service_account" {
  project      = var.project_id
  account_id   = "${var.name}-pool"
  display_name = "Terraform-managed service account for ${var.name} GKE cluster node pools"
}

resource "google_project_iam_member" "node_pool_service_account-log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.node_pool_service_account.email}"
}

resource "google_project_iam_member" "node_pool_service_account-metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.node_pool_service_account.email}"
}

resource "google_project_iam_member" "node_pool_service_account-monitoring_viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.node_pool_service_account.email}"
}

resource "google_project_iam_member" "node_pool_service_account-resourceMetadata-writer" {
  project = var.project_id
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = "serviceAccount:${google_service_account.node_pool_service_account.email}"
}

resource "google_project_iam_member" "node_pool_service_account-gcr" {
  for_each = toset(var.registry_project_ids)
  project  = each.key
  role     = "roles/storage.objectViewer"
  member   = "serviceAccount:${google_service_account.node_pool_service_account.email}"
}

resource "google_project_iam_member" "node_pool_service_account-artifact-registry" {
  for_each = toset(var.registry_project_ids)
  project  = each.key
  role     = "roles/artifactregistry.reader"
  member   = "serviceAccount:${google_service_account.node_pool_service_account.email}"
}
